## =====================================================================
##  Did national suicide-prevention strategies reduce suicide?
##  PRIMARY ANALYSIS (R).  ALL DATA REAL (Eurostat suicide SDR + WB unemployment).
##
##  9-step checklist:
##   1 covariate choice  2 balance  3 propensity score  4 panelview rollout
##   5 cohort counts/shares  6 outcome by cohort  7 weighted target parameter
##   8 CS simple + event study  9 Rambachan-Roth (HonestDiD) sensitivity
##  + robustness (BJS, Sun-Abraham, not-yet-treated, +GDP, leave-one-out)
##  + falsifications (pre-trends, in-space placebo)
##
##  Identification note: with 4 treated countries and 1-2 units per cohort,
##  propensity-score weighting is not credible; we use REGRESSION ADJUSTMENT
##  (est_method="reg") conditioning on unemployment -- the dominant time-varying
##  suicide confound (Ruhm 2000; Reeves et al. 2012). DR/IPW reported as robustness.
## =====================================================================
suppressPackageStartupMessages({
  library(data.table); library(did); library(fixest)
  library(didimputation); library(HonestDiD); library(ggplot2); library(jsonlite)
})
set.seed(20260604)
`%||%` <- function(a,b) if(is.null(a)) b else a
ROOT <- "/Users/scunning/the-remix-tour/ispra/claude"
FIG <- file.path(ROOT,"output","figures"); TAB <- file.path(ROOT,"output","tables"); RES <- file.path(ROOT,"output")
for(p in c(FIG,TAB,RES)) dir.create(p,FALSE,TRUE)

theme_set(theme_minimal(base_size=12)+theme(panel.grid.minor=element_blank(),
  plot.title=element_text(face="bold"), plot.subtitle=element_text(color="grey30"),
  legend.position="bottom"))
TEAL<-"#1F6F6B"; CORAL<-"#C44536"; GOLD<-"#C9982A"; INK<-"#26323C"

## ---- load + construct balanced panel ----
d <- fread(file.path(ROOT,"data","clean","panel.csv"))
d[, log_gdp := log(gdp_real_pc)]
span <- min(d$year):max(d$year)
d0 <- d[!(geo %in% c("FI","FR"))]                 # drop always-treated (FI) & no-pre-period (FR)
comp <- d0[!is.na(suicide_sdr) & !is.na(unemp), .(ok=all(span %in% year)), by=geo][ok==TRUE]
main <- d0[geo %in% comp$geo & !is.na(suicide_sdr) & !is.na(unemp)]
main[, cid := .GRP, by=geo]
main[, gvar := as.numeric(gvar)]                  # MUST be numeric (did codes never-treated as Inf)
main[, cohort := ifelse(gvar==0,"Never treated",paste0("Adopted ",gvar))]

cat(sprintf("BALANCED MAIN: %d obs, %d countries (%d treated), %d-%d\n",
    nrow(main), uniqueN(main$geo), uniqueN(main[gvar>0]$geo), min(main$year), max(main$year)))
print(main[gvar>0, .(g=first(gvar)), by=.(geo,country)][order(g)])

## =====================================================================
## STEP 6  Outcome by cohort (descriptive) -- include Italy as the never-adopter hook
## =====================================================================
oc <- main[, .(suicide=mean(suicide_sdr)), by=.(cohort,year)]
p6 <- ggplot(oc, aes(year,suicide,color=cohort,group=cohort))+
  geom_line(linewidth=1)+geom_point(size=1.3)+
  scale_color_manual(values=c("Never treated"=INK,"Adopted 1995"=TEAL,"Adopted 2002"=CORAL,"Adopted 2005"=GOLD))+
  annotate("rect",xmin=2008,xmax=2010,ymin=-Inf,ymax=Inf,alpha=.08,fill="red")+
  annotate("text",x=2009,y=max(oc$suicide),label="Great\nRecession",size=3,color="grey40")+
  labs(title="Suicide mortality by adoption cohort",
       subtitle="Age-standardised suicide rate per 100,000 (Eurostat)",x=NULL,y="Suicide rate per 100,000",color=NULL)
ggsave(file.path(FIG,"fig6_outcome_by_cohort.pdf"),p6,width=8,height=5)

## =====================================================================
## STEP 4  panelview-style rollout
## =====================================================================
pv <- copy(main); pv[, on:=as.integer(gvar>0 & year>=gvar)]
pv[, lab:=sprintf("%s",country)]
ord <- pv[,.(g=first(gvar)),by=lab][order(g==0,g)]
pv[, lab:=factor(lab,levels=rev(ord$lab))]
p4 <- ggplot(pv,aes(year,lab,fill=factor(on)))+geom_tile(color="white",linewidth=.3)+
  scale_fill_manual(values=c("0"="grey85","1"=CORAL),labels=c("No national strategy","Strategy in force"))+
  labs(title="Staggered adoption of national suicide-prevention strategies",
       subtitle="Treatment status by country and year (balanced estimation sample)",x=NULL,y=NULL,fill=NULL)
ggsave(file.path(FIG,"fig4_panelview.pdf"),p4,width=8.5,height=5.5)

## =====================================================================
## STEP 5  cohort counts + shares
## =====================================================================
cc <- main[,.(n_country=uniqueN(geo)),by=cohort][order(-n_country)]
cc[, share:=round(100*n_country/sum(n_country),1)]
fwrite(cc,file.path(TAB,"tab5_cohort_counts.csv"))
p5 <- ggplot(cc,aes(reorder(cohort,-n_country),n_country,fill=cohort))+geom_col(width=.7)+
  geom_text(aes(label=sprintf("%d (%.0f%%)",n_country,share)),vjust=-0.4,size=3.5)+
  scale_fill_manual(values=c("Never treated"=INK,"Adopted 1995"=TEAL,"Adopted 2002"=CORAL,"Adopted 2005"=GOLD),guide="none")+
  labs(title="Cohort composition",x=NULL,y="Number of countries")+ylim(0,max(cc$n_country)*1.15)
ggsave(file.path(FIG,"fig5_cohort_counts.pdf"),p5,width=7,height=4.5)

## =====================================================================
## STEP 1+2  covariate choice + balance table (baseline year per country)
## =====================================================================
base <- main[,.SD[which.min(year)],by=geo]; base[,ever:=as.integer(gvar>0)]
covs <- c("suicide_sdr","gdp_real_pc","unemp","share65","medage")
bal <- rbindlist(lapply(covs,function(v){
  t<-base[ever==1][[v]]; c0<-base[ever==0][[v]]
  sp<-sqrt((var(t,na.rm=TRUE)+var(c0,na.rm=TRUE))/2)
  sd<-(mean(t,na.rm=TRUE)-mean(c0,na.rm=TRUE))/sp
  data.table(variable=v,treated_mean=mean(t,na.rm=TRUE),control_mean=mean(c0,na.rm=TRUE),
             std_diff=sd,
             # Imbens & Rubin (2015): |std. diff| > 0.25 is "imbalanced"
             imbalanced=ifelse(is.na(sd),NA,ifelse(abs(sd)>0.25,"yes","no")))}))
fwrite(bal,file.path(TAB,"tab2_balance.csv")); print(bal)

## =====================================================================
## STEP 3  propensity score (country baseline) + overlap  [descriptive only]
## =====================================================================
ps <- suppressWarnings(glm(ever~scale(unemp)+scale(share65)+scale(medage),data=base,family=binomial))
base[, pscore:=predict(ps,type="response")]
fwrite(base[,.(geo,country,ever,pscore)],file.path(TAB,"tab3_pscore.csv"))
p3 <- ggplot(base,aes(pscore,fill=factor(ever)))+geom_density(alpha=.5,adjust=1.2)+
  scale_fill_manual(values=c("0"=INK,"1"=CORAL),labels=c("Never treated","Ever treated"))+
  labs(title="Propensity-score overlap",subtitle="Baseline covariates; descriptive common-support check",
       x="Estimated P(ever adopts a strategy)",y="Density",fill=NULL)
ggsave(file.path(FIG,"fig3_pscore_overlap.pdf"),p3,width=7,height=4.5)

## =====================================================================
## STEP 7+8  Callaway & Sant'Anna -- group-time ATTs + aggregations
## =====================================================================
## base_period="universal": all event-study coefficients (pre AND post) are
## LONG differences from the fixed g-1 baseline -- consistent with the parallel-
## trends assumption and with how post-treatment effects are computed.
csfit <- function(data,xf=~unemp,est="reg",ctrl="nevertreated"){
  att_gt(yname="suicide_sdr",tname="year",idname="cid",gname="gvar",xformla=xf,
         data=data,control_group=ctrl,est_method=est,base_period="universal",
         allow_unbalanced_panel=FALSE,bstrap=TRUE,biters=2000,cband=TRUE)
}
cs <- csfit(main)
saveRDS(cs,file.path(RES,"cs_attgt.rds"))
agg_simple <- aggte(cs,type="simple",na.rm=TRUE)
agg_group  <- aggte(cs,type="group",na.rm=TRUE)     # WEIGHTED TARGET (group-size weighted)
agg_dyn    <- aggte(cs,type="dynamic",na.rm=TRUE,min_e=-8,max_e=8)
agg_cal    <- aggte(cs,type="calendar",na.rm=TRUE)
sink(file.path(RES,"cs_summary.txt"))
cat("== simple ==\n");print(summary(agg_simple))
cat("\n== group (WEIGHTED) ==\n");print(summary(agg_group))
cat("\n== dynamic ==\n");print(summary(agg_dyn))
cat("\n== calendar ==\n");print(summary(agg_cal)); sink()

## event-study figure
es <- data.table(e=agg_dyn$egt,att=agg_dyn$att.egt,se=agg_dyn$se.egt)
es[,`:=`(lo=att-1.96*se,hi=att+1.96*se,post=e>=0)]
p8 <- ggplot(es,aes(e,att))+geom_hline(yintercept=0,color="grey50")+
  geom_vline(xintercept=-.5,linetype="dashed",color="grey60")+
  geom_ribbon(aes(ymin=lo,ymax=hi),alpha=.15,fill=CORAL)+
  geom_line(color=CORAL,linewidth=.8)+geom_point(aes(color=post),size=2)+
  scale_color_manual(values=c("FALSE"=INK,"TRUE"=CORAL),guide="none")+
  labs(title="Event study: national strategies and suicide",
       subtitle="Callaway & Sant'Anna (2021), regression-adjusted for unemployment",
       x="Years since strategy adoption",y="ATT (suicide per 100,000)")
ggsave(file.path(FIG,"fig8_event_study.pdf"),p8,width=8,height=5)

## calendar-time figure (exposes the Great-Recession confound)
ct <- data.table(year=agg_cal$egt,att=agg_cal$att.egt,se=agg_cal$se.egt)
p8c <- ggplot(ct,aes(year,att))+geom_hline(yintercept=0,color="grey50")+
  geom_ribbon(aes(ymin=att-1.96*se,ymax=att+1.96*se),alpha=.15,fill=TEAL)+
  geom_line(color=TEAL,linewidth=.8)+geom_point(color=TEAL,size=2)+
  annotate("rect",xmin=2008,xmax=2010,ymin=-Inf,ymax=Inf,alpha=.08,fill="red")+
  labs(title="Calendar-time ATT",subtitle="Treatment effects load on the post-2008 recession years",
       x=NULL,y="ATT (suicide per 100,000)")
ggsave(file.path(FIG,"fig8c_calendar.pdf"),p8c,width=8,height=4.5)

## =====================================================================
## STEP 9  Rambachan & Roth (2023) sensitivity via HonestDiD
## =====================================================================
rr <- tryCatch({
  hd <- HonestDiD::honest_did(agg_dyn, e=0, type="relative_magnitude",
                              Mbarvec=seq(0,2,by=0.5))
  hd
}, error=function(e){ message("honest_did(AGGTE) failed: ",conditionMessage(e)); NULL })
if(is.null(rr)){
  ## manual fallback: build betahat + sigma from influence function
  rr <- tryCatch({
    inf <- agg_dyn$inf.function$dynamic.inf.func.e
    n <- nrow(inf); Sig <- crossprod(inf)/(n^2)
    e <- agg_dyn$egt; keep <- e!=-1
    b <- agg_dyn$att.egt[keep]; S <- Sig[keep,keep]
    npre <- sum(e[keep]<0); npost<-sum(e[keep]>=0)
    rm <- createSensitivityResults_relativeMagnitudes(betahat=b,sigma=S,
            numPrePeriods=npre,numPostPeriods=npost,Mbarvec=seq(0,2,by=0.5))
    list(robust_ci=rm,npre=npre,npost=npost)
  }, error=function(e){message("HonestDiD manual failed: ",conditionMessage(e)); NULL})
}
if(!is.null(rr)){
  saveRDS(rr,file.path(RES,"honestdid.rds"))
  pr <- as.data.table(if(!is.null(rr$robust_ci)) rr$robust_ci else rr)
  if(all(c("lb","ub") %in% names(pr))){
    p9 <- ggplot(pr,aes(x=factor(round(Mbar,2))))+
      geom_errorbar(aes(ymin=lb,ymax=ub),width=.15,color=CORAL,linewidth=.8)+
      geom_hline(yintercept=0,color="grey50")+
      labs(title="Rambachan & Roth (2023) sensitivity",
           subtitle="Relative-magnitudes restriction; robust 95% CI for ATT at e=0",
           x=expression(bar(M)),y="Robust confidence set")
    ggsave(file.path(FIG,"fig9_honestdid.pdf"),p9,width=7.5,height=4.5)
  }
}

## =====================================================================
## ROBUSTNESS
## =====================================================================
robust <- list()
robust$dr     <- tryCatch(aggte(csfit(main,est="dr"),type="group",na.rm=TRUE),error=function(e)NULL)
robust$uncond <- tryCatch(aggte(csfit(main,xf=~1,est="reg"),type="group",na.rm=TRUE),error=function(e)NULL)
robust$nyt    <- tryCatch(aggte(csfit(main,ctrl="notyettreated"),type="group",na.rm=TRUE),error=function(e)NULL)
## + GDP covariate on the sub-sample with GDP observed
mg <- main[!is.na(log_gdp)]; comp2 <- mg[,.(ok=all(span %in% year)),by=geo][ok==TRUE]
mg <- mg[geo %in% comp2$geo]; mg[,cid:=.GRP,by=geo]
robust$gdp <- tryCatch(aggte(att_gt(yname="suicide_sdr",tname="year",idname="cid",gname="gvar",
   xformla=~unemp+log_gdp,data=mg,control_group="nevertreated",est_method="reg",
   base_period="universal",allow_unbalanced_panel=FALSE,bstrap=TRUE,biters=1000),type="group",na.rm=TRUE),
   error=function(e)NULL)

## BJS (Borusyak, Jaravel & Spiess 2024)
bjs <- tryCatch(did_imputation(data=main,yname="suicide_sdr",gname="gvar",tname="year",
   idname="cid",first_stage=~unemp|cid+year),error=function(e){message("BJS:",conditionMessage(e));NULL})
if(!is.null(bjs)) fwrite(as.data.table(bjs),file.path(TAB,"tab_bjs.csv"))
## BJS event study
bjs_es <- tryCatch(did_imputation(data=main,yname="suicide_sdr",gname="gvar",tname="year",
   idname="cid",first_stage=~unemp|cid+year,horizon=TRUE,pretrends=-8:-1),error=function(e)NULL)
if(!is.null(bjs_es)) fwrite(as.data.table(bjs_es),file.path(TAB,"tab_bjs_eventstudy.csv"))

## Sun & Abraham (2021)
sa_dat <- copy(main); sa_dat[,cohort_g:=ifelse(gvar==0,10000,gvar)]
sa <- tryCatch(feols(suicide_sdr~unemp+sunab(cohort_g,year)|cid+year,data=sa_dat,cluster=~cid),
               error=function(e){message("SA:",conditionMessage(e));NULL})
if(!is.null(sa)){ saveRDS(sa,file.path(RES,"sunab.rds"))
  sink(file.path(RES,"sunab_summary.txt")); print(summary(sa,agg="att")); sink() }

## three-estimator event-study overlay
es_overlay <- data.table()
es_overlay <- rbind(es_overlay, data.table(method="Callaway-Sant'Anna",e=es$e,att=es$att,se=es$se))
if(!is.null(bjs_es)){ b<-as.data.table(bjs_es); b<-b[!is.na(term)]
  es_overlay <- rbind(es_overlay, data.table(method="Borusyak et al.",e=as.numeric(b$term),att=b$estimate,se=b$std.error),fill=TRUE)}
if(!is.null(sa)){ sac<-as.data.table(summary(sa)$coeftable,keep.rownames="term")
  sac<-sac[grepl("year::",term)]; sac[,e:=as.numeric(gsub(".*year::(-?[0-9]+).*","\\1",term))]
  es_overlay <- rbind(es_overlay, data.table(method="Sun-Abraham",e=sac$e,att=sac$Estimate,se=sac$`Std. Error`),fill=TRUE)}
fwrite(es_overlay,file.path(TAB,"tab_eventstudy_overlay.csv"))
po <- ggplot(es_overlay[e>=-8 & e<=8],aes(e,att,color=method,fill=method))+
  geom_hline(yintercept=0,color="grey50")+geom_vline(xintercept=-.5,linetype="dashed",color="grey70")+
  geom_line(linewidth=.7,position=position_dodge(.3))+geom_point(size=1.6,position=position_dodge(.3))+
  scale_color_manual(values=c("Callaway-Sant'Anna"=CORAL,"Borusyak et al."=TEAL,"Sun-Abraham"=GOLD))+
  scale_fill_manual(values=c("Callaway-Sant'Anna"=CORAL,"Borusyak et al."=TEAL,"Sun-Abraham"=GOLD))+
  labs(title="Event study across three heterogeneity-robust estimators",
       subtitle="Callaway-Sant'Anna, Borusyak-Jaravel-Spiess, Sun-Abraham",
       x="Years since adoption",y="ATT (suicide per 100,000)",color=NULL,fill=NULL)
ggsave(file.path(FIG,"fig_robust_overlay.pdf"),po,width=8.5,height=5)

## leave-one-out (drop each treated country)
loo <- rbindlist(lapply(sort(unique(main[gvar>0]$geo)),function(gg){
  m<-main[geo!=gg]; m[,cid:=.GRP,by=geo]
  a<-tryCatch(aggte(csfit(m),type="group",na.rm=TRUE),error=function(e)NULL)
  if(is.null(a)) return(NULL)
  data.table(dropped=gg,att=a$overall.att,se=a$overall.se)}))
fwrite(loo,file.path(TAB,"tab_leaveoneout.csv")); print(loo)

## =====================================================================
## FALSIFICATIONS
## =====================================================================
## in-space placebo: random fake adoption among never-treated controls
placebo_space <- function(B=300){
  nt<-sort(unique(main[gvar==0]$geo)); yrs<-c(1998,2002,2005); out<-numeric(0)
  for(b in 1:B){
    m<-main[gvar==0]; m[,gvar:=0]
    fake<-sample(nt,4); fy<-sample(yrs,4,replace=TRUE)
    for(i in seq_along(fake)) m[geo==fake[i],gvar:=fy[i]]
    m[,cid:=.GRP,by=geo]; m[,gvar:=as.numeric(gvar)]
    a<-tryCatch(aggte(att_gt(yname="suicide_sdr",tname="year",idname="cid",gname="gvar",xformla=~unemp,
       data=m,control_group="nevertreated",est_method="reg",base_period="universal",
       allow_unbalanced_panel=FALSE,bstrap=FALSE),type="group",na.rm=TRUE),error=function(e)NULL)
    if(!is.null(a)) out<-c(out,a$overall.att)
  }
  out[is.finite(out)]
}
pl <- placebo_space(300); fwrite(data.table(placebo_att=pl),file.path(TAB,"tab_placebo_space.csv"))
placebo_p <- mean(abs(pl)>=abs(agg_group$overall.att),na.rm=TRUE)
pf <- ggplot(data.table(x=pl),aes(x))+geom_histogram(bins=30,fill="grey80",color="white")+
  geom_vline(xintercept=agg_group$overall.att,color=CORAL,linewidth=1.1)+
  annotate("text",x=agg_group$overall.att,y=Inf,vjust=2,hjust=-.1,label="observed",color=CORAL,size=3.2)+
  labs(title="In-space placebo",subtitle="ATT under randomly assigned fake adoption among controls",
       x="Placebo ATT",y="Count")
ggsave(file.path(FIG,"fig_falsification_placebo.pdf"),pf,width=7.5,height=4.5)

## =====================================================================
## REFEREE-REQUESTED ROBUSTNESS (round 1): drop post-communist controls,
## alternative Sweden coding (2008), and one-year anticipation.
## =====================================================================
gv <- function(x) if(is.null(x)) NA_real_ else x
ref_rob <- list()
m_nopc <- main[!geo %in% c("CZ","EE","HU","SI")]; m_nopc[,cid:=.GRP,by=geo]
ref_rob$drop_postcommunist <- tryCatch(aggte(csfit(m_nopc),type="group",na.rm=TRUE),error=function(e)NULL)
m_se08 <- copy(main); m_se08[geo=="SE",gvar:=2008]; m_se08[,cid:=.GRP,by=geo]
ref_rob$sweden2008 <- tryCatch(aggte(csfit(m_se08),type="group",na.rm=TRUE),error=function(e)NULL)
ref_rob$anticipation1 <- tryCatch(aggte(att_gt(yname="suicide_sdr",tname="year",idname="cid",gname="gvar",
  xformla=~unemp,data=main,control_group="nevertreated",est_method="reg",base_period="universal",
  anticipation=1,allow_unbalanced_panel=FALSE,bstrap=TRUE,biters=2000),type="group",na.rm=TRUE),error=function(e)NULL)
ref_tab <- data.table(
  spec=c("drop post-communist controls","Sweden recoded 2008","anticipation = 1 year"),
  att=c(gv(ref_rob$drop_postcommunist$overall.att),gv(ref_rob$sweden2008$overall.att),gv(ref_rob$anticipation1$overall.att)),
  se =c(gv(ref_rob$drop_postcommunist$overall.se), gv(ref_rob$sweden2008$overall.se), gv(ref_rob$anticipation1$overall.se)))
fwrite(ref_tab, file.path(TAB,"tab_referee_robustness.csv")); print(ref_tab)

## =====================================================================
## DUMP machine-readable estimates for cross-language replication
## =====================================================================
res <- list(
  n_obs=nrow(main), n_countries=uniqueN(main$geo), n_treated=uniqueN(main[gvar>0]$geo),
  treated=sort(unique(main[gvar>0]$geo)), years=range(main$year),
  outcome_mean_overall=mean(main$suicide_sdr),
  outcome_mean_treated=mean(main[gvar>0]$suicide_sdr),
  outcome_mean_control=mean(main[gvar==0]$suicide_sdr),
  unemp_mean=mean(main$unemp),
  cs_simple_att=agg_simple$overall.att, cs_simple_se=agg_simple$overall.se,
  cs_group_att=agg_group$overall.att, cs_group_se=agg_group$overall.se,
  cs_dr_att=gv(robust$dr$overall.att), cs_uncond_att=gv(robust$uncond$overall.att),
  cs_nyt_att=gv(robust$nyt$overall.att), cs_gdp_att=gv(robust$gdp$overall.att),
  bjs_att=if(!is.null(bjs)) bjs$estimate[1] else NA, bjs_se=if(!is.null(bjs)) bjs$std.error[1] else NA,
  sa_att=if(!is.null(sa)) as.numeric(coef(summary(sa,agg="att"))["ATT"]) else NA,
  es_e=es$e, es_att=es$att, es_se=es$se,
  pretrend_sumz2=sum((es[e<0]$att/es[e<0]$se)^2,na.rm=TRUE),
  placebo_p=placebo_p)
write_json(res,file.path(RES,"estimates.json"),auto_unbox=TRUE,pretty=TRUE,digits=6)

cat("\n=========== KEY RESULTS ===========\n")
cat(sprintf("N=%d obs, %d countries (%d treated: %s), %d-%d\n",res$n_obs,res$n_countries,
    res$n_treated,paste(res$treated,collapse=","),res$years[1],res$years[2]))
cat(sprintf("Suicide mean: overall=%.3f treated=%.3f control=%.3f\n",
    res$outcome_mean_overall,res$outcome_mean_treated,res$outcome_mean_control))
cat(sprintf("CS simple  ATT = %+.3f (se %.3f)\n",res$cs_simple_att,res$cs_simple_se))
cat(sprintf("CS GROUP   ATT = %+.3f (se %.3f)   <-- WEIGHTED TARGET\n",res$cs_group_att,res$cs_group_se))
cat(sprintf("CS dr=%.3f uncond=%.3f notyet=%.3f +gdp=%.3f\n",res$cs_dr_att,res$cs_uncond_att,res$cs_nyt_att,res$cs_gdp_att))
cat(sprintf("BJS ATT=%.3f   SA ATT=%.3f\n",res$bjs_att,res$sa_att))
cat(sprintf("Pre-trend sum z^2 (df=%d) = %.2f\n",sum(es$e<0),res$pretrend_sumz2))
cat(sprintf("In-space placebo p = %.3f\n",res$placebo_p))
cat("===================================\nDONE.\n")
