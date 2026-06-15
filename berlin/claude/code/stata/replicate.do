*  Cross-language replication (STATA) of the R Callaway-Sant'Anna primary result.
*  Verifies N, means, and the CS ATT via csdid (Rios-Avila/Callaway-Sant'Anna).
clear all
set more off
capture ssc install csdid, replace
capture ssc install drdid, replace

import delimited "/Users/scunning/the-remix-tour/ispra/claude/data/clean/panel.csv", clear varnames(1)

* numeric outcome/covariate (csv may import as string if any NA)
destring suicide_sdr unemp gvar year, replace force ignore("NA")

* reproduce the R balanced sample: drop FI, FR; keep countries with complete suicide & unemp over full span
drop if inlist(geo,"FI","FR")
drop if missing(suicide_sdr) | missing(unemp)
egen cid = group(geo)
bys geo: gen n = _N
qui sum year
local T = r(max)-r(min)+1
keep if n==`T'                 // balanced countries only
drop n

di "=== STATA sample check ==="
qui sum suicide_sdr
di "N obs = " r(N) "   overall mean = " %6.3f r(mean)
qui sum suicide_sdr if gvar>0 & gvar<.
di "treated mean = " %6.3f r(mean)
qui sum suicide_sdr if gvar==0
di "control mean = " %6.3f r(mean)
qui tab geo if gvar>0 & gvar<.

* Callaway & Sant'Anna, regression adjustment, never-treated controls, +unemp
csdid suicide_sdr unemp, ivar(cid) time(year) gvar(gvar) method(reg) notyet

estat simple
estat group
estat event

di "=== compare to R: simple=3.053  group(weighted)=2.729 ==="
