## =====================================================================
##  Goodman-Bacon (2021) decomposition of the TWFE estimate.
##  Run the static TWFE regression, then decompose the single coefficient
##  into its 2x2 building blocks and show that their weighted average
##  reconstructs the TWFE number exactly.
## =====================================================================
suppressPackageStartupMessages({library(data.table);library(fixest);library(bacondecomp);library(ggplot2)})
ROOT<-"/Users/scunning/the-remix-tour/ispra/claude"
FIG<-file.path(ROOT,"output","figures");TAB<-file.path(ROOT,"output","tables")
CORAL<-"#C44536";TEAL<-"#1F6F6B";GOLD<-"#C9982A";INK<-"#26323C"

d<-fread(file.path(ROOT,"data","clean","panel.csv"));span<-min(d$year):max(d$year)
d0<-d[!(geo%in%c("FI","FR"))];comp<-d0[!is.na(suicide_sdr)&!is.na(unemp),.(ok=all(span%in%year)),by=geo][ok==TRUE]
m<-d0[geo%in%comp$geo&!is.na(suicide_sdr)&!is.na(unemp)]
m[,cid:=.GRP,by=geo];m[,gvar:=as.numeric(gvar)]
m[,treat:=as.integer(gvar>0 & year>=gvar)]
m<-as.data.frame(m)

## ---- 1. the TWFE regression we are decomposing ----
twfe<-feols(suicide_sdr~treat|cid+year,data=m)
b_twfe<-as.numeric(coef(twfe)["treat"])
cat(sprintf("TWFE coefficient on treat = %.4f\n",b_twfe))

## ---- 2. Goodman-Bacon decomposition (uncontrolled, balanced panel) ----
bd<-bacon(suicide_sdr~treat,data=m,id_var="cid",time_var="year")
setDT(bd)
## collapse to component types: weighted mean estimate within type, total weight
comp_tab<-bd[,.(weight=sum(weight),avg_estimate=sum(weight*estimate)/sum(weight)),by=type]
comp_tab[,contribution:=weight*avg_estimate]
recon<-sum(comp_tab$contribution)
comp_tab<-rbind(comp_tab,
  data.table(type="--- Reconstructed TWFE (sum) ---",weight=sum(comp_tab$weight),
             avg_estimate=NA,contribution=recon))
comp_tab<-rbind(comp_tab,
  data.table(type="Actual TWFE coefficient",weight=NA,avg_estimate=NA,contribution=b_twfe))
fwrite(comp_tab,file.path(TAB,"tab_bacon.csv"))
cat("\n=== Goodman-Bacon decomposition ===\n");print(comp_tab)
cat(sprintf("\nReconstruction check: sum(weight*estimate)=%.4f  vs TWFE=%.4f  diff=%.2e\n",
    recon,b_twfe,recon-b_twfe))

## ---- 3. Bacon scatter: weight vs 2x2 estimate, by comparison type ----
p<-ggplot(bd,aes(weight,estimate,color=type,shape=type))+
  geom_hline(yintercept=b_twfe,linetype="dashed",color=INK)+
  geom_point(size=2.6,alpha=.85)+
  annotate("text",x=max(bd$weight)*0.6,y=b_twfe,vjust=-0.6,
           label=sprintf("TWFE = %.2f",b_twfe),color=INK,size=3.3)+
  scale_color_manual(values=c(CORAL,TEAL,GOLD))+
  labs(title="Goodman-Bacon decomposition of the TWFE estimate",
       subtitle="Each point is a 2x2 DiD comparison; TWFE is their weighted average",
       x="Bacon weight",y="2x2 DiD estimate",color=NULL,shape=NULL)
ggsave(file.path(FIG,"fig_bacon.pdf"),p,width=8,height=5)
cat("\nWrote tab_bacon.csv and fig_bacon.pdf\n")
