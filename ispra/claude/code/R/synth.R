## =====================================================================
##  ROBUSTNESS: Augmented Synthetic Control (Ridge-ASCM)
##  One synthetic control per treated unit. Donor pool = 12 never-treated.
##  Credible only for UK (2002, 8 pre-periods) and IE (2005, 11 pre-periods).
##  Norway & Sweden (1995) have a SINGLE pre-period -> SCM infeasible (documented).
##
##  Deliverables (per Abadie et al.):
##   (1) characteristics table: treated vs synthetic predictor means
##   (2) pre/post fit plot (observed treated vs synthetic)
##   (3) gap event-study (treated - synthetic)
##   (4) placebo inference: spaghetti plot + post/pre RMSPE-ratio histogram
## =====================================================================
suppressPackageStartupMessages({library(data.table);library(augsynth);library(ggplot2)})
set.seed(20260604)
ROOT<-"/Users/scunning/the-remix-tour/ispra/claude"
FIG<-file.path(ROOT,"output","figures");TAB<-file.path(ROOT,"output","tables");RES<-file.path(ROOT,"output")
theme_set(theme_minimal(base_size=12)+theme(panel.grid.minor=element_blank(),
  plot.title=element_text(face="bold"),plot.subtitle=element_text(color="grey30"),legend.position="bottom"))
CORAL<-"#C44536";TEAL<-"#1F6F6B";INK<-"#26323C";GOLD<-"#C9982A"

d<-fread(file.path(ROOT,"data","clean","panel.csv")); d[,log_gdp:=log(gdp_real_pc)]
span<-min(d$year):max(d$year)
d0<-d[!(geo %in% c("FI","FR"))]
comp<-d0[!is.na(suicide_sdr)&!is.na(unemp),.(ok=all(span %in% year)),by=geo][ok==TRUE]
P<-d0[geo %in% comp$geo & !is.na(suicide_sdr)&!is.na(unemp)]
controls<-sort(unique(P[gvar==0]$geo))
adopt<-c(UK=2002, IE=2005)

## ---- helper: run Ridge-ASCM for a focal unit vs control donor pool ----
run_ascm<-function(focal, t_int, donors){
  dat<-P[geo %in% c(focal,donors), .(geo,year,suicide_sdr,unemp)]
  dat[,trt:=as.integer(geo==focal & year>=t_int)]
  as<-tryCatch(augsynth(suicide_sdr~trt, unit=geo, time=year, data=as.data.frame(dat),
                        t_int=t_int, progfunc="ridge", scm=TRUE),error=function(e)NULL)
  if(is.null(as)) return(NULL)
  s<-summary(as, inf=FALSE)
  att<-as.data.table(s$att)            # Time, Estimate (= observed - synthetic gap)
  setnames(att, c("Time","Estimate"), c("year","gap"), skip_absent=TRUE)
  obs<-dat[geo==focal, .(year, obs=suicide_sdr)]
  att<-merge(att, obs, by="year", all.x=TRUE)
  att[, synth:=obs-gap]
  pre<-att[year< t_int]; post<-att[year>=t_int]
  rmspe_pre<-sqrt(mean(pre$gap^2,na.rm=TRUE)); rmspe_post<-sqrt(mean(post$gap^2,na.rm=TRUE))
  list(obj=as, att=att, w=as$weights, rmspe_pre=rmspe_pre, rmspe_post=rmspe_post,
       ratio=rmspe_post/rmspe_pre, t_int=t_int, focal=focal)
}

placebo_results<-list()
for(focal in names(adopt)){
  t_int<-adopt[[focal]]; donors<-controls
  cat(sprintf("\n=== Ridge-ASCM: %s (adopt %d), %d donors ===\n",focal,t_int,length(donors)))
  fit<-run_ascm(focal,t_int,donors)
  if(is.null(fit)){cat("  augsynth failed\n");next}
  cat(sprintf("  pre-RMSPE=%.3f post-RMSPE=%.3f ratio=%.2f  ATT(post mean gap)=%.3f\n",
      fit$rmspe_pre,fit$rmspe_post,fit$ratio,mean(fit$att[year>=t_int]$gap)))

  ## (1) characteristics table: treated vs synthetic predictor means (pre-period)
  pre_yrs<-span[span< t_int]
  preds<-c("suicide_sdr","unemp","share65","medage","gdp_real_pc")
  w<-fit$w[,1]; wdt<-data.table(geo=rownames(fit$w), w=w)
  chars<-rbindlist(lapply(preds,function(v){
    tv<-mean(P[geo==focal & year %in% pre_yrs][[v]],na.rm=TRUE)
    don<-P[geo %in% donors & year %in% pre_yrs, .(m=mean(get(v),na.rm=TRUE)), by=geo]
    don<-merge(don,wdt,by="geo"); sv<-sum(don$w*don$m)/sum(don$w)
    data.table(variable=v, treated=tv, synthetic=sv)}))
  fwrite(chars,file.path(TAB,sprintf("tab_synth_chars_%s.csv",focal))); print(chars)

  ## (2) pre/post fit + (3) gap event-study
  pf<-ggplot(fit$att,aes(year))+
    geom_vline(xintercept=t_int-.5,linetype="dashed",color="grey60")+
    geom_line(aes(y=obs,color="Observed"),linewidth=1)+
    geom_line(aes(y=synth,color="Synthetic"),linewidth=1,linetype="22")+
    scale_color_manual(values=c("Observed"=CORAL,"Synthetic"=INK),name=NULL)+
    labs(title=sprintf("%s: observed vs synthetic suicide rate",focal),
         subtitle="Ridge-augmented synthetic control (augsynth)",x=NULL,y="Suicide per 100,000")
  ggsave(file.path(FIG,sprintf("fig_synth_fit_%s.pdf",focal)),pf,width=7.5,height=4.6)
  gp<-ggplot(fit$att,aes(year-t_int,gap))+geom_hline(yintercept=0,color="grey50")+
    geom_vline(xintercept=-.5,linetype="dashed",color="grey60")+
    geom_line(color=CORAL,linewidth=.9)+geom_point(color=CORAL,size=1.8)+
    labs(title=sprintf("%s: gap (treated - synthetic)",focal),
         subtitle="Synthetic-control event study",x="Years since adoption",y="Gap in suicide per 100,000")
  ggsave(file.path(FIG,sprintf("fig_synth_gap_%s.pdf",focal)),gp,width=7.5,height=4.6)

  ## (4) placebo: treat each donor as fake-treated at same t_int
  placebos<-rbindlist(lapply(donors,function(g){
    f<-run_ascm(g, t_int, setdiff(donors,g))
    if(is.null(f)) return(NULL)
    f$att[,.(unit=g,e=year-t_int,gap,ratio=f$ratio)]
  }),fill=TRUE)
  focal_g<-fit$att[,.(unit=focal,e=year-t_int,gap,ratio=fit$ratio)]
  allg<-rbind(placebos,focal_g)
  fwrite(allg,file.path(TAB,sprintf("tab_synth_placebo_%s.csv",focal)))

  ## spaghetti
  sp<-ggplot()+
    geom_hline(yintercept=0,color="grey60")+geom_vline(xintercept=-.5,linetype="dashed",color="grey70")+
    geom_line(data=placebos,aes(e,gap,group=unit),color="grey75",alpha=.7,linewidth=.4)+
    geom_line(data=focal_g,aes(e,gap),color=CORAL,linewidth=1.1)+
    labs(title=sprintf("Placebo inference: %s vs %d control placebos",focal,length(donors)),
         subtitle="Gap trajectories under synthetic control (focal in red)",
         x="Years since (placebo) adoption",y="Gap in suicide per 100,000")
  ggsave(file.path(FIG,sprintf("fig_synth_spaghetti_%s.pdf",focal)),sp,width=7.5,height=4.6)

  ## RMSPE-ratio histogram + p-value
  ratios<-unique(allg[,.(unit,ratio)])[is.finite(ratio)]
  pval<-mean(ratios$ratio>=fit$ratio,na.rm=TRUE)
  rh<-ggplot(ratios,aes(ratio))+geom_histogram(bins=15,fill="grey80",color="white")+
    geom_vline(xintercept=fit$ratio,color=CORAL,linewidth=1.1)+
    annotate("text",x=fit$ratio,y=Inf,vjust=2,hjust=-.1,
             label=sprintf("%s  (p=%.2f)",focal,pval),color=CORAL,size=3.3)+
    labs(title=sprintf("Post/pre RMSPE ratio: %s vs placebos",focal),
         subtitle="Abadie placebo inference",x="Post/pre RMSPE ratio",y="Count")
  ggsave(file.path(FIG,sprintf("fig_synth_rmspe_%s.pdf",focal)),rh,width=7.5,height=4.4)

  placebo_results[[focal]]<-list(ratio=fit$ratio,pval=pval,att_post=mean(fit$att[year>=t_int]$gap),
                                 rmspe_pre=fit$rmspe_pre,rmspe_post=fit$rmspe_post)
  cat(sprintf("  placebo p-value (RMSPE-ratio rank) = %.3f\n",pval))
}

jsonlite::write_json(placebo_results,file.path(RES,"synth_results.json"),auto_unbox=TRUE,pretty=TRUE,digits=5)
cat("\nSYNTH ROBUSTNESS DONE.\n")
