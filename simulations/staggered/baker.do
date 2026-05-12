********************************************************************************
* name: baker.do
* author: scott cunningham (baylor) adapting andrew baker (stanford)
* description: illustrate TWFE with differential timing and
*              heterogenous treatment effects over time
* last updated: jan 5, 2022
********************************************************************************

clear
capture log close
set seed 20200403

* 1,000 firms (25 per state), 40 states, 4 groups (250 per groups), 30 years
* First create the states
set obs 40
gen state = _n

* Finally generate 1000 firms.  These are in each state. So 25 per state.
expand 25
bysort state: gen firms=runiform(0,5)
label variable firms "Unique firm fixed effect per state"

* Second create the years
expand 30
sort state
bysort state firms: gen year = _n
gen n=year
replace year = 1980 if year==1
replace year = 1981 if year==2
replace year = 1982 if year==3
replace year = 1983 if year==4
replace year = 1984 if year==5
replace year = 1985 if year==6
replace year = 1986 if year==7
replace year = 1987 if year==8
replace year = 1988 if year==9
replace year = 1989 if year==10
replace year = 1990 if year==11
replace year = 1991 if year==12
replace year = 1992 if year==13
replace year = 1993 if year==14
replace year = 1994 if year==15
replace year = 1995 if year==16
replace year = 1996 if year==17
replace year = 1997 if year==18
replace year = 1998 if year==19
replace year = 1999 if year==20
replace year = 2000 if year==21
replace year = 2001 if year==22
replace year = 2002 if year==23
replace year = 2003 if year==24
replace year = 2004 if year==25
replace year = 2005 if year==26
replace year = 2006 if year==27
replace year = 2007 if year==28
replace year = 2008 if year==29
replace year = 2009 if year==30
egen id = group(state firms)

* Add 250 firms treated every period with the treatment effect still 7 on average
* Cohort years 1986, 1992, 1998, 2004
su state, detail
gen     group=0
replace group=1 if state<=`r(p25)'
replace group=2 if state>`r(p25)' & state<=`r(p50)'
replace group=3 if state>`r(p50)' & state<=`r(p75)'
replace group=4 if state>`r(p75)' & `r(p75)'!=.

gen     treat_date = 0
replace treat_date = 1986 if group==1
replace treat_date = 1992 if group==2
replace treat_date = 1998 if group==3
replace treat_date = 2004 if group==4

gen     treat=0
replace treat=1 if group==1 & year>=1986
replace treat=1 if group==2 & year>=1992
replace treat=1 if group==3 & year>=1998
replace treat=1 if group==4 & year>=2004

* Data generating process
gen e   = rnormal(0,(0.5)^2)
gen te1 = rnormal(10,(0.2)^2)
gen te2 = rnormal(8,(0.2)^2)
gen te3 = rnormal(6,(0.2)^2)
gen te4 = rnormal(4,(0.2)^2)
gen te  = .
replace te = te1 if group == 1
replace te = te2 if group == 2
replace te = te3 if group == 3
replace te = te4 if group == 4

************************************************************************
* DGP: heterogeneous treatment effects, dynamic over time
* For group 1, the ATT in 1986 is 10
* For group 1, the ATT in 1987 is 20
* For group 1, the ATT in 1988 is 30 and so on
* This is what we mean by "dynamic treatment effects" or "heterogeneity over time"
************************************************************************

* Y(0): the untreated potential outcome
gen y0 = firms + n + e

* Y(1) under CONSTANT treatment effects: y0 plus the group-specific te, applied if treated
gen y2 = y0 + te*treat

* Y(1) under DYNAMIC treatment effects: te grows each year since treatment
gen te_dynamic = te*treat*(year - treat_date + 1)
gen y  = y0 + te_dynamic

* The truth (for the dynamic-effects DGP):
su te_dynamic if treat == 1
display "True average ATT (across cohorts and post-periods, dynamic) = " r(mean)

* The truth (for the constant-effects DGP):
su te if treat == 1
display "True average ATT (across cohorts, constant) = " r(mean)

* Estimation using TWFE - constant treatment effects
areg y2 i.year treat, a(id) robust

* Estimation using TWFE - dynamic treatment effects over time
areg y  i.year treat, a(id) robust

* Sun and Abraham event study commentary: leads and lags
gen     time_til=year-treat_date
ta      time_til, gen(dd)

* Event study with heterogeneity, dropping two leads
areg y i.year dd1 - dd23 dd25-dd48, a(id) robust

coefplot, keep(dd1 dd2 dd3 dd4 dd5 dd6 dd7 dd8 dd9 dd10 dd11 dd12 dd13 dd14 dd15 dd16 dd17 dd18 dd19 dd20 dd22 dd23 dd25 dd26 dd27 dd28 dd29 dd30 dd31 dd32 dd33 dd34 dd35 dd36 dd37 dd38 dd39 dd40 dd41 dd42) xlabel(, angle(vertical)) yline(0) vertical msymbol(D) mfcolor(white) ciopts(lwidth(*3) lcolor(*.6)) grid(between) mlabel format(%9.3f) mlabposition(12) mlabgap(*2) title(Baker simulation)

* Bacon decomposition shows the problem
net install ddtiming, from(https://raw.githubusercontent.com/tgoldring/ddtiming/master)
areg y i.year treat, a(id) robust
ddtiming y treat, i(id) t(year)

* Bacon decomposition on the constant treatment effects
areg y2 i.year treat, a(id) robust
ddtiming y2 treat, i(id) t(year)

* Or use the new command in Stata 17 on as a post-estimation
xtdidregress (y) (treat), group(id) time(year)
estat bdecomp, graph

* Save for the R code
save ./baker.dta, replace

capture log close
exit
