* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* name:        equivalence.do
* author:      scott cunningham
* description: Five equivalent paths to the 2x2 DiD on castle.dta.
*              Manual 2x2, OLS with interactions, TWFE, first-difference on
*              treatment dummy, and across-group difference on the post dummy.
*              All five return the same coefficient.
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
capture log close

use https://github.com/scunning1975/mixtape/raw/master/castle.dta, clear
xtset sid year

* Keep only states adopting in 2006 + never-treated states.
drop if effyear==2005 | effyear==2007 | effyear==2008 | effyear==2009

drop  post
gen   post = 0
replace post = 1 if year>=2006

gen   treat = 0
replace treat = 1 if effyear==2006

keep if year==2006 | year==2005


* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* PATH 1: Manual 2x2 (Snow's "long differences": four averages, three subtractions)
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
summarize l_homicide if treat==1 & post==1
gen y11 = `r(mean)'
summarize l_homicide if treat==1 & post==0
gen y10 = `r(mean)'
summarize l_homicide if treat==0 & post==1
gen y01 = `r(mean)'
summarize l_homicide if treat==0 & post==0
gen y00 = `r(mean)'

gen did_manual = (y11 - y10) - (y01 - y00)
display "Path 1 (Manual 2x2): " did_manual


* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* PATH 2: OLS with treat x post interaction (the "saturated" specification)
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
reg l_homicide post##treat, cluster(sid)


* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* PATH 3: TWFE (state and year fixed effects), DD coefficient on treat x post
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xtreg l_homicide c.treat#c.post i.year, fe vce(cluster sid)


* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* PATH 4: First-difference within unit, regressed on the treatment dummy
*         (Delta Y_i regressed on D_i)
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preserve
    keep sid year l_homicide treat
    reshape wide l_homicide, i(sid) j(year)
    gen diff = l_homicide2006 - l_homicide2005
    reg diff treat, vce(cluster sid)
restore


* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* PATH 5: Across-group difference (treated minus control by year),
*         regressed on the post dummy.
*         This is the Frisch-Waugh-Lovell mirror of Path 4: same coefficient.
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
preserve
    collapse (mean) l_homicide, by(treat year post)
    reshape wide l_homicide, i(year post) j(treat)
    gen gap = l_homicide1 - l_homicide0
    reg gap post
restore


* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
* Now repeat the five paths with population weights.
* %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

* Manual 2x2 weighted
summarize l_homicide if treat==1 & post==1 [aw=popwt]
gen wy11 = `r(mean)'
summarize l_homicide if treat==1 & post==0 [aw=popwt]
gen wy10 = `r(mean)'
summarize l_homicide if treat==0 & post==1 [aw=popwt]
gen wy01 = `r(mean)'
summarize l_homicide if treat==0 & post==0 [aw=popwt]
gen wy00 = `r(mean)'

gen wdid = (wy11 - wy10) - (wy01 - wy00)
display "Weighted manual 2x2: " wdid

* Weighted OLS with interactions
reg l_homicide post##treat [aweight=popwt], cluster(sid)

* Weighted TWFE
xtreg l_homicide c.treat#c.post i.year [aw=popwt], fe vce(cluster sid)

* Weighted first-difference on treatment
preserve
    keep sid year l_homicide popwt treat
    reshape wide l_homicide popwt , i(sid) j(year)
    gen diff = l_homicide2006 - l_homicide2005
    reg diff treat [aw=popwt2005], vce(cluster sid)
restore

* Weighted across-group difference on post (uses popwt within the collapse)
preserve
    collapse (mean) l_homicide [aw=popwt], by(treat year post)
    reshape wide l_homicide, i(year post) j(treat)
    gen gap = l_homicide1 - l_homicide0
    reg gap post
restore

capture log close
exit
