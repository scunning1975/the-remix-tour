## =====================================================================
##  DiD is inappropriate here (levels + trends differ) -> SYNTHETIC CONTROL.
##  Extended spliced panel 1986-2010 (WHO chained to Eurostat).
##
##  (A) DiD diagnostic: unconditional CS event study (universal base) + pre-trend
##      slope test + extrapolation -> shows the design fails (DDDiD).
##  (B) Augmented (ridge) SCM for ALL FOUR treated units, each with:
##      characteristics table, observed-vs-synthetic fit, gap event study,
##      donor weights BEFORE (SCM) and AFTER (ridge) augmentation, permutation
##      (placebo spaghetti + post/pre RMSPE-ratio histogram).
##  (C) Synthetic DiD per timing group (Arkhangelsky et al. 2021).
## =====================================================================
suppressPackageStartupMessages({library(data.table);library(augsynth);library(synthdid)
  library(did);library(ggplot2);library(jsonlite)})
set.seed(20260604)
ROOT<-"/Users/scunning/the-remix-tour/ispra/claude"
FIG<-file.path(ROOT,"output","figures");TAB<-file.path(ROOT,"output","tables");RES<-file.path(ROOT,"output")
theme_set(theme_minimal(base_size=12)+theme(panel.grid.minor=element_blank(),
  plot.title=element_text(face="bold"),plot.subtitle=element_text(color="grey30"),legend.position="bottom"))
CORAL<-"#C44536";TEAL<-"#1F6F6B";GOLD<-"#C9982A";INK<-"#26323C"

P<-fread(file.path(ROOT,"data","clean","panel_extended.csv"))
P[,suicide:=as.numeric(suicide)]; P<-P[!is.na(suicide)]
P[,gvar:=as.numeric(gvar)]; P[,cid:=.GRP,by=geo]
controls<-sort(unique(P[gvar==0]$geo))
adopt<-c(NO=1995,SE=1995,UK=2002,IE=2005)
cat(sprintf("EXTENDED PANEL: %d obs, %d countries (%d treated), %d-%d; %d controls\n",
    nrow(P),uniqueN(P$geo),uniqueN(P[gvar>0]$geo),min(P$year),max(P$year),length(controls)))

## =====================================================================
## (A) DiD diagnostic on the long panel: the pre-trend that kills DiD
## =====================================================================
cs<-att_gt(yname="suicide",tname="year",idname="cid",gname="gvar",data=P,
   control_group="nevertreated",est_method="reg",base_period="universal",
   allow_unbalanced_panel=FALSE,bstrap=TRUE,biters=2000)
dyn<-aggte(cs,type="dynamic",na.rm=TRUE,min_e=-12,max_e=12)
es<-data.table(e=dyn$egt,att=dyn$att.egt,se=dyn$se.egt)
fitidx<-es$e< -1 & is.finite(es$se)
wls<-lm(att~e,data=es[fitidx],weights=1/se^2)
slope<-coef(wls)[2]; slope_t<-summary(wls)$coef[2,3]
es[,line:=coef(wls)[1]+slope*e]
cat(sprintf("(A) extended-panel pre-trend slope=%.3f/yr (t=%.2f, p=%.3f)\n",
    slope,slope_t,2*pnorm(-abs(slope_t))))
pA<-ggplot(es,aes(e,att))+geom_hline(yintercept=0,color="grey60")+geom_vline(xintercept=-.5,linetype="dashed",color="grey60")+
  geom_ribbon(aes(ymin=att-1.96*se,ymax=att+1.96*se),alpha=.12,fill=CORAL)+
  geom_line(aes(y=line),color=INK,linetype="22")+
  geom_point(aes(color=e>=0),size=1.9)+geom_line(color=CORAL,alpha=.4)+
  scale_color_manual(values=c("FALSE"=INK,"TRUE"=CORAL),guide="none")+
  labs(title="Why difference-in-differences fails here",
       subtitle=sprintf("A pre-existing upward trend (%.2f/yr, t=%.1f) runs straight through adoption; dashed line = pre-trend extrapolation",slope,slope_t),
       x="Years since adoption",y="ATT (suicide per 100,000)")
ggsave(file.path(FIG,"fig_did_fails.pdf"),pA,width=8.5,height=5)
fwrite(es,file.path(TAB,"tab_did_extrap.csv"))

## =====================================================================
## (B) Augmented synthetic control for ALL FOUR treated units
## =====================================================================
fit_unit<-function(focal,t_int){
  d<-P[geo %in% c(focal,controls),.(geo,year,suicide)]
  d[,trt:=as.integer(geo==focal & year>=t_int)]; d<-as.data.frame(d)
  scm <-augsynth(suicide~trt,unit=geo,time=year,data=d,t_int=t_int,progfunc="None", scm=TRUE)
  ridg<-augsynth(suicide~trt,unit=geo,time=year,data=d,t_int=t_int,progfunc="Ridge",scm=TRUE)
  att<-as.data.table(summary(ridg,inf=FALSE)$att); setnames(att,c("Time","Estimate"),c("year","gap"),skip_absent=TRUE)
  obs<-as.data.table(d)[geo==focal,.(year,obs=suicide)]; att<-merge(att,obs,by="year",all.x=TRUE)
  att[,synth:=obs-gap]
  pre<-att[year<t_int]; post<-att[year>=t_int]
  list(scm=scm,ridge=ridg,att=att,
       w_scm=scm$weights[,1],w_ridge=ridg$weights[,1],
       rmspe_pre=sqrt(mean(pre$gap^2,na.rm=TRUE)),rmspe_post=sqrt(mean(post$gap^2,na.rm=TRUE)),
       att_post=mean(post$gap,na.rm=TRUE),t_int=t_int,focal=focal)
}
placebo_unit<-function(focal,t_int,donors){
  out<-rbindlist(lapply(donors,function(g){
    d<-P[geo %in% c(g,setdiff(donors,g)),.(geo,year,suicide)]
    d[,trt:=as.integer(geo==g & year>=t_int)]; d<-as.data.frame(d)
    a<-tryCatch(augsynth(suicide~trt,unit=geo,time=year,data=d,t_int=t_int,progfunc="Ridge",scm=TRUE),error=function(e)NULL)
    if(is.null(a))return(NULL)
    at<-as.data.table(summary(a,inf=FALSE)$att); setnames(at,c("Time","Estimate"),c("year","gap"),skip_absent=TRUE)
    pre<-at[year<t_int]$gap; post<-at[year>=t_int]$gap
    at[,`:=`(unit=g,e=year-t_int,ratio=sqrt(mean(post^2,na.rm=TRUE))/sqrt(mean(pre^2,na.rm=TRUE)))]
    at[,.(unit,e,gap,ratio)]
  }),fill=TRUE); out
}

scm_summary<-list()
for(u in names(adopt)){
  t_int<-adopt[[u]]; cat(sprintf("\n=== SCM %s (adopt %d) ===\n",u,t_int))
  f<-fit_unit(u,t_int)
  cat(sprintf("  pre-RMSPE=%.3f post-RMSPE=%.3f ratio=%.2f post-gap=%.3f\n",
      f$rmspe_pre,f$rmspe_post,f$rmspe_post/f$rmspe_pre,f$att_post))

  ## characteristics: pre-period mean outcome treated vs synthetic (ridge weights)
  pre_yrs<-min(P$year):(t_int-1)
  tv<-mean(P[geo==u & year %in% pre_yrs]$suicide)
  wdt<-data.table(geo=names(f$w_ridge),w=f$w_ridge)
  don<-P[geo %in% controls & year %in% pre_yrs,.(m=mean(suicide)),by=geo]
  don<-merge(don,wdt,by="geo",all.x=TRUE); don[is.na(w),w:=0]
  sv<-sum(don$w*don$m)/sum(don$w)
  fwrite(data.table(unit=u,variable="pre-period mean suicide",treated=round(tv,2),synthetic=round(sv,2)),
         file.path(TAB,sprintf("tab_scm_chars_%s.csv",u)))

  ## fit
  pf<-ggplot(f$att,aes(year))+geom_vline(xintercept=t_int-.5,linetype="dashed",color="grey60")+
    geom_line(aes(y=obs,color="Observed"),linewidth=1)+geom_line(aes(y=synth,color="Synthetic"),linewidth=1,linetype="22")+
    scale_color_manual(values=c("Observed"=CORAL,"Synthetic"=INK),name=NULL)+
    labs(title=sprintf("%s: observed vs synthetic",u),subtitle="Ridge-augmented synthetic control (spliced panel, 1986-2010)",
         x=NULL,y="Suicide per 100,000")
  ggsave(file.path(FIG,sprintf("fig_scm_fit_%s.pdf",u)),pf,width=7.5,height=4.5)

  ## gap event study
  gp<-ggplot(f$att,aes(year-t_int,gap))+geom_hline(yintercept=0,color="grey60")+geom_vline(xintercept=-.5,linetype="dashed",color="grey60")+
    geom_line(color=CORAL,linewidth=.9)+geom_point(color=CORAL,size=1.6)+
    labs(title=sprintf("%s: gap (treated - synthetic)",u),subtitle="Synthetic-control event study",
         x="Years since adoption",y="Gap in suicide per 100,000")
  ggsave(file.path(FIG,sprintf("fig_scm_gap_%s.pdf",u)),gp,width=7.5,height=4.5)

  ## donor weights BEFORE (SCM) and AFTER (Ridge) augmentation
  wb<-data.table(geo=names(f$w_scm),SCM=f$w_scm,Ridge=f$w_ridge)
  wl<-melt(wb,id.vars="geo",variable.name="method",value.name="weight")
  wl<-wl[geo %in% wb[abs(SCM)>0.01 | abs(Ridge)>0.01]$geo]   # show donors that matter
  pw<-ggplot(wl,aes(reorder(geo,weight),weight,fill=method))+
    geom_col(position="dodge",width=.7)+coord_flip()+geom_hline(yintercept=0,color="grey60")+
    scale_fill_manual(values=c("SCM"=INK,"Ridge"=CORAL))+
    labs(title=sprintf("%s: donor weights before vs after ridge augmentation",u),
         subtitle="SCM (simplex, non-negative) vs ridge-augmented (bias-corrected; may go negative)",
         x=NULL,y="Donor weight",fill=NULL)
  ggsave(file.path(FIG,sprintf("fig_scm_weights_%s.pdf",u)),pw,width=7.5,height=4.6)
  fwrite(wb,file.path(TAB,sprintf("tab_scm_weights_%s.csv",u)))

  ## permutation
  pl<-placebo_unit(u,t_int,controls)
  fcl<-f$att[,.(unit=u,e=year-t_int,gap,ratio=f$rmspe_post/f$rmspe_pre)]
  sp<-ggplot()+geom_hline(yintercept=0,color="grey60")+geom_vline(xintercept=-.5,linetype="dashed",color="grey70")+
    geom_line(data=pl,aes(e,gap,group=unit),color="grey75",alpha=.7,linewidth=.4)+
    geom_line(data=fcl,aes(e,gap),color=CORAL,linewidth=1.1)+
    labs(title=sprintf("Permutation inference: %s vs %d control placebos",u,length(controls)),
         subtitle="Gap trajectories (focal in red)",x="Years since (placebo) adoption",y="Gap")
  ggsave(file.path(FIG,sprintf("fig_scm_spaghetti_%s.pdf",u)),sp,width=7.5,height=4.5)
  ratios<-unique(rbind(pl[,.(unit,ratio)],fcl[,.(unit,ratio)]))[is.finite(ratio)]
  pval<-mean(ratios$ratio>=fcl$ratio[1],na.rm=TRUE)
  rh<-ggplot(ratios,aes(ratio))+geom_histogram(bins=14,fill="grey80",color="white")+
    geom_vline(xintercept=fcl$ratio[1],color=CORAL,linewidth=1.1)+
    annotate("text",x=fcl$ratio[1],y=Inf,vjust=2,hjust=-.1,label=sprintf("%s (p=%.2f)",u,pval),color=CORAL,size=3.2)+
    labs(title=sprintf("%s: post/pre RMSPE ratio vs placebos",u),subtitle="Abadie permutation inference",
         x="Post/pre RMSPE ratio",y="Count")
  ggsave(file.path(FIG,sprintf("fig_scm_rmspe_%s.pdf",u)),rh,width=7.5,height=4.4)
  scm_summary[[u]]<-list(t_int=t_int,rmspe_pre=f$rmspe_pre,rmspe_post=f$rmspe_post,
                         ratio=f$rmspe_post/f$rmspe_pre,att_post=f$att_post,pval=pval)
  cat(sprintf("  permutation p=%.3f\n",pval))
}

## =====================================================================
## (C) Synthetic DiD per timing group (Arkhangelsky et al. 2021)
## =====================================================================
sdid_group<-function(treated_geos,t_int){
  g<-P[geo %in% c(treated_geos,controls),.(geo,year,suicide)]
  g[,trt:=as.integer(geo %in% treated_geos & year>=t_int)]
  setup<-tryCatch(panel.matrices(as.data.frame(g),unit="geo",time="year",outcome="suicide",treatment="trt"),error=function(e)NULL)
  if(is.null(setup))return(NULL)
  est<-synthdid_estimate(setup$Y,setup$N0,setup$T0)
  se<-tryCatch(sqrt(vcov(est,method="placebo")),error=function(e)NA)
  list(att=as.numeric(est),se=as.numeric(se))
}
groups<-list("1995 (NO,SE)"=list(g=c("NO","SE"),t=1995),
             "2002 (UK)"=list(g="UK",t=2002),"2005 (IE)"=list(g="IE",t=2005))
sdid<-rbindlist(lapply(names(groups),function(nm){
  r<-sdid_group(groups[[nm]]$g,groups[[nm]]$t)
  if(is.null(r))return(data.table(group=nm,sdid_att=NA,se=NA))
  data.table(group=nm,sdid_att=round(r$att,3),se=round(r$se,3))
}))
fwrite(sdid,file.path(TAB,"tab_sdid_groups.csv")); cat("\n=== Synthetic DiD per timing group ===\n"); print(sdid)

jsonlite::write_json(list(scm=scm_summary,sdid=sdid,
  did_pretrend_slope=as.numeric(slope),did_pretrend_t=as.numeric(slope_t)),
  file.path(RES,"scm_results.json"),auto_unbox=TRUE,pretty=TRUE,digits=5)
cat("\nSCM/SDID DONE.\n")
