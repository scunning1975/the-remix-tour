**********************************************************************
* name: comparing_did.do
* author: scott cunningham (baylor)
* description: DiD analog of comparing.do. Heterogeneous treatment
*              effects + covariate imbalance + a covariate-driven
*              post-period trend (conditional PT violated). Shows
*              which estimators recover the ATT and which don't.
**********************************************************************

clear
capture log close
set seed 5150

* 5,000 individuals
set obs 5000
gen id = _n

* Half are treated, half are control
gen     treat = 0
replace treat = 1 in 2501/5000

* Imbalance: treated are younger with lower GPA.
* This is selection on observables --- and it's going to bite us.
gen     age = rnormal(27, 3.5)  if treat == 1
replace age = rnormal(30, 4)    if treat == 0
gen     gpa = rnormal(2.2, 0.5) if treat == 1
replace gpa = rnormal(2.5, 1)   if treat == 0

* Re-center so coefficients read cleanly
su age
replace age = age - r(mean)
su gpa
replace gpa = gpa - r(mean)

gen age_sq = age^2
gen gpa_sq = gpa^2

* Make this a 2-period panel: 1990 (pre), 1991 (post)
expand 2
sort id
bysort id: gen year = _n
replace year = 1990 if year == 1
replace year = 1991 if year == 2

gen post = 0
replace post = 1 if year == 1991

**********************************************************************
* Data generating process
**********************************************************************

gen e = rnormal(0, 5)

* Y(0) in the pre-period: depends on age and gpa
gen y0_pre = 15000 + 10.25*age - 10.5*age_sq + 1000*gpa - 10.5*gpa_sq + e

* Y(0) in the post-period: covariate-driven trend added
* This is the key: untreated outcomes trend differently for different
* values of X. Conditional PT is violated.
gen y0_post = y0_pre + 200 + 50*age + 200*gpa + rnormal(0, 5)

* Stack into one column
gen y0 = y0_pre if post == 0
replace y0 = y0_post if post == 1

* Y(1) in the post period: ATT depends on age and gpa
* Heterogeneous treatment effects in X
gen y1 = y0
replace y1 = y0 + 2500 + 100*age + 1100*gpa if post == 1

* Individual treatment effect
gen delta = y1 - y0

**********************************************************************
* The truth: ATT averaged over the treated X-distribution in the post period
**********************************************************************

su delta if treat == 1 & post == 1
display "True ATT = " r(mean)
* Should be near 1962 given the treated age/gpa distribution

* Observed outcome via switching equation
gen d = treat * post
gen earnings = d*y1 + (1-d)*y0

**********************************************************************
* Estimator 1: Naive DiD (no covariates)
**********************************************************************

reg earnings i.treat##i.post, robust
* The coefficient on `1.treat#1.post` is the naive DiD.
* It will pick up the covariate-driven trend as if it were treatment.
* This is BIASED.

**********************************************************************
* Estimator 2: DiD with additive X (Scott's published spec)
**********************************************************************

reg earnings i.treat##i.post age age_sq gpa gpa_sq, robust
* Coefficient on `1.treat#1.post` is the DiD with additive X.
* Additive controls help a little but can't capture heterogeneous TE.
* This is STILL BIASED.

**********************************************************************
* Estimator 3: Outcome regression (Heckman, Ichimura, and Todd 1997)
**********************************************************************

preserve
keep id treat year earnings age age_sq gpa gpa_sq
reshape wide earnings, i(id treat age age_sq gpa gpa_sq) j(year)
gen dY = earnings1991 - earnings1990

* Fit dY on X using CONTROLS ONLY
reg dY age age_sq gpa gpa_sq if treat == 0
predict mu0_hat, xb

* OR-DiD: average residual gap for the treated
gen residual = dY - mu0_hat
su residual if treat == 1
display "OR-DiD ATT estimate = " r(mean)
* Should be close to the truth if the linear model is right
restore

**********************************************************************
* Estimator 4: Inverse propensity weighting (Abadie 2005)
**********************************************************************

preserve
keep id treat year earnings age age_sq gpa gpa_sq
reshape wide earnings, i(id treat age age_sq gpa gpa_sq) j(year)
gen dY = earnings1991 - earnings1990

* Estimate propensity score with logit
logit treat age age_sq gpa gpa_sq
predict phat, pr

* Weight: treated = 1, controls = p/(1-p)
gen w = 1 if treat == 1
replace w = phat / (1 - phat) if treat == 0

* IPW-DiD
sum dY if treat == 1
local mean_T = r(mean)
sum dY [aw=w] if treat == 0
local mean_C = r(mean)
display "IPW-DiD ATT estimate = " `mean_T' - `mean_C'
* Should be close to the truth if the propensity score is right
restore

**********************************************************************
* Estimator 5: Doubly robust DiD (Sant'Anna and Zhao 2020)
**********************************************************************

* Requires: ssc install drdid
drdid earnings age age_sq gpa gpa_sq, ivar(id) time(year) tr(treat) all
* `all` reports OR, IPW, DR-IPW, and DR-improved side by side.
* DR is unbiased if EITHER the outcome model OR the propensity score is right.

**********************************************************************
* What we just saw
**********************************************************************

display ""
display "True ATT in the post period = 1962 (approximately)"
display ""
display "Naive DiD            --- BIASED (covariate-driven trend)"
display "DiD with additive X  --- STILL BIASED (heterogeneous TE)"
display "OR-DiD               --- close, if outcome model is right"
display "IPW-DiD              --- close, if propensity score is right"
display "DR-DiD               --- closest, only need ONE model right"

capture log close
exit
