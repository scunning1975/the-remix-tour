## Referee 2 round-2 independent verification of the three NEW robustness numbers
## claimed in paper.tex / author response: drop-post-communist +1.24 (se .76),
## Sweden-2008 +2.41, anticipation +1.68. Referee code only; does not touch author code.
suppressMessages({library(data.table); library(did)})
ROOT <- "/Users/scunning/the-remix-tour/ispra/claude"
d <- fread(file.path(ROOT,"data","clean","panel.csv"))
span <- min(d$year):max(d$year)
d0 <- d[!(geo %in% c("FI","FR"))]
comp <- d0[!is.na(suicide_sdr) & !is.na(unemp), .(ok=all(span %in% year)), by=geo][ok==TRUE]
main <- d0[geo %in% comp$geo & !is.na(suicide_sdr) & !is.na(unemp)]
main[, gvar := as.numeric(gvar)]

csfit <- function(dt, anticip=0){
  dt[, cid := .GRP, by=geo]
  aggte(att_gt(yname="suicide_sdr",tname="year",idname="cid",gname="gvar",xformla=~unemp,
    data=dt,control_group="nevertreated",est_method="reg",base_period="varying",
    anticipation=anticip,allow_unbalanced_panel=FALSE,bstrap=TRUE,biters=2000),
    type="group",na.rm=TRUE)
}

## (1) drop post-communist controls CZ EE HU SI
m1 <- copy(main)[!(geo %in% c("CZ","EE","HU","SI"))]
a1 <- csfit(m1)
cat(sprintf("DROP-POSTCOMMUNIST: %.3f (se %.3f)\n", a1$overall.att, a1$overall.se))

## (2) Sweden recoded to 2008
m2 <- copy(main); m2[geo=="SE", gvar:=2008]
a2 <- csfit(m2)
cat(sprintf("SWEDEN-2008: %.3f (se %.3f)\n", a2$overall.att, a2$overall.se))

## (3) one year anticipation
a3 <- csfit(copy(main), anticip=1)
cat(sprintf("ANTICIPATION-1: %.3f (se %.3f)\n", a3$overall.att, a3$overall.se))
