********************************************************************************
* name: ddd2.do
* author: scott cunningham (baylor)
* description: simulation for triple diff with potential outcomes but using a biased did and an unbiased triple diff
* last updated: dec 22, 2023
********************************************************************************

clear
capture log close
set seed 20200403

* States, Groups, and Time Setup
set obs 40
gen state = _n

* Generate treatment groups
gen experimental = 0
replace experimental = 1 in 1/20

* 50 cities per state
expand 50
bysort state: gen city_no = _n
egen city = group(city_no state)
drop city_no

* Three groups per city: men (1), married women (2), and older women (3)
expand 3
bysort city state: gen worker = _n
egen id = group(worker city state)

* Time, 10 years
expand 10
sort state
bysort state city worker: gen year = _n

* Setting years
replace year = 2010 if year == 1
replace year = 2011 if year == 2
replace year = 2012 if year == 3
replace year = 2013 if year == 4
replace year = 2014 if year == 5
replace year = 2015 if year == 6
replace year = 2016 if year == 7
replace year = 2017 if year == 8
replace year = 2018 if year == 9
replace year = 2019 if year == 10

* Define the after period (post-2015)
gen after = year >= 2015

* Baseline earnings in 2010 with different values for experimental and non-experimental states
gen 	baseline = 40000 if worker == 3  // Married women
replace baseline = 45000 if worker == 2  // Older women
replace baseline = 50000 if worker == 1  // Men

* Adjust baseline for experimental states
replace baseline = 1.5 * baseline if experimental == 1

* Annual wage growth for Y(0)
gen year_diff = year - 2010

* Setting trends for states and groups
gen state_trend = 1000 if experimental == 1
replace state_trend = 1500 if experimental == 0

gen group_trend = 500 if worker == 2
replace group_trend = 1000 if worker == 1 | worker == 3

* Annual wage growth for Y(0) incorporating state and group trends
gen y0 = baseline + state_trend * year_diff + group_trend * year_diff

* Adding random error to Y(0)
gen error = rnormal(0, 1500)
replace y0 = y0 + error

* Define Y(1) with an ATT of -$5000 for married women in experimental states post-2015
gen 	y1 = y0
replace y1 = y0 - 5000 if experimental == 1 & worker == 2 & after == 1

* Treatment effect
gen delta = y1-y0
su delta if after==1 & experimental ==1 & worker==2
display "True ATT (married women in mandate states, post-2015) = " r(mean)
gen att = `r(mean)'

* Treatment indicator
gen 	treat = 0
replace treat = 1 if experimental == 1 & worker == 2 & after == 1

* Final earnings using switching equation
gen earnings = treat * y1 + (1 - treat) * y0

****************************************************************************
* Calculating the 8 averages
****************************************************************************

* 1. After, Married, Experimental
egen avg_wage_ame = mean(earnings) if after == 1 & experimental == 1 & worker == 2
* 2. Before, Married, Experimental
egen avg_wage_bme = mean(earnings) if after == 0 & experimental == 1 & worker == 2
* 3. After, Single Men and Older Women, Experimental
egen avg_wage_asoe = mean(earnings) if after == 1 & experimental == 1 & worker != 2
* 4. Before, Single Men and Older Women, Experimental
egen avg_wage_bsoe = mean(earnings) if after == 0 & experimental == 1 & worker != 2
* 5. After, Married, Non-Experimental
egen avg_wage_amn = mean(earnings) if after == 1 & experimental == 0 & worker == 2
* 6. Before, Married, Non-Experimental
egen avg_wage_bmn = mean(earnings) if after == 0 & experimental == 0 & worker == 2
* 7. After, Single Men and Older Women, Non-Experimental
egen avg_wage_ason = mean(earnings) if after == 1 & experimental == 0 & worker != 2
* 8. Before, Single Men and Older Women, Non-Experimental
egen avg_wage_bson = mean(earnings) if after == 0 & experimental == 0 & worker != 2

****************************************************************************
* Biased DiD Case 1: married women to married women but in different states
****************************************************************************
summarize avg_wage_ame, meanonly
local after_married_exp = r(mean)
summarize avg_wage_bme, meanonly
local before_married_exp = r(mean)
summarize avg_wage_amn, meanonly
local after_married_nonexp = r(mean)
summarize avg_wage_bmn, meanonly
local before_married_nonexp = r(mean)

local DiD_case1 = (`after_married_exp' - `before_married_exp') - (`after_married_nonexp' - `before_married_nonexp')
display "Difference-in-Differences Estimate: " `DiD_case1'

* Regression event study for biased DID.
gen 	treated1=0
replace treated1=1 if experimental==1 & worker==2
replace treated1=. if worker~=2

reg earnings treated1##after, cluster(state)
reg earnings treated1##ib2014.year, cluster(state)

coefplot, keep(1.treated1#*) omitted baselevels cirecast(rcap) ///
    rename(1.treated1#([0-9]+).year = \1, regex) at(_coef) ///
    yline(0, lp(solid)) yline(-5000, lp(dot)) xline(2014.5, lpattern(dash)) ///
    xlab(2010(1)2019)

****************************************************************************
* Biased DiD Case 2: Comparing Married Women to Men and Older Women within Experimental States
****************************************************************************
summarize avg_wage_ame, meanonly
local after_married_exp = r(mean)
summarize avg_wage_bme, meanonly
local before_married_exp = r(mean)
summarize avg_wage_asoe, meanonly
local after_control_exp = r(mean)
summarize avg_wage_bsoe, meanonly
local before_control_exp = r(mean)

local DiD_case2 = (`after_married_exp' - `before_married_exp') - (`after_control_exp' - `before_control_exp')
display "Difference-in-Differences Estimate (Case 2): " `DiD_case2'

* Illustrate the parallel trends bias
summarize y0 if experimental == 1 & worker == 2 & after == 0
scalar avg_y0_before_married_exp = r(mean)
summarize y0 if experimental == 1 & worker == 2 & after == 1
scalar avg_y0_after_married_exp = r(mean)
scalar l_t = avg_y0_after_married_exp - avg_y0_before_married_exp

summarize y0 if experimental == 1 & (worker == 1 | worker == 3) & after == 0
scalar avg_y0_before_control_exp = r(mean)
summarize y0 if experimental == 1 & (worker == 1 | worker == 3) & after == 1
scalar avg_y0_after_control_exp = r(mean)
scalar s_t = avg_y0_after_control_exp - avg_y0_before_control_exp

display "l_t (Married Women in Experimental States): " l_t
display "s_t (Single Men and Older Women in Experimental States): " s_t
scalar non_pt = l_t-s_t
display "Non-parallel trends bias is " non_pt

* Regression event study for second biased DID.
gen 	treated2=0
replace treated2=1 if experimental==1 & worker==2
replace treated2=. if experimental==0

reg earnings treated2##after, cluster(state)
reg earnings treated2##ib2014.year, cluster(state)

coefplot, keep(1.treated2#*) omitted baselevels cirecast(rcap) ///
    rename(1.treated2#([0-9]+).year = \1, regex) at(_coef) ///
    yline(0, lp(solid)) yline(-5000, lp(dot)) xline(2014.5, lpattern(dash)) ///
    xlab(2010(1)2019)

****************************************************************************
* Unbiased triple differences
****************************************************************************
summarize avg_wage_asoe, meanonly
local after_control_exp = r(mean)
summarize avg_wage_bsoe, meanonly
local before_control_exp = r(mean)
summarize avg_wage_ason, meanonly
local after_control_nonexp = r(mean)
summarize avg_wage_bson, meanonly
local before_control_nonexp = r(mean)

local DiD_married_exp = (`after_married_exp' - `before_married_exp')
local DiD_control_exp = (`after_control_exp' - `before_control_exp')
local DiD_married_nonexp = (`after_married_nonexp' - `before_married_nonexp')
local DiD_control_nonexp = (`after_control_nonexp' - `before_control_nonexp')

local TripleDiff = (`DiD_married_exp' - `DiD_control_exp') - (`DiD_married_nonexp' - `DiD_control_nonexp')
display "Triple Difference Estimate: " `TripleDiff'

* Triple diff regression
gen 	married_women = 0
replace married_women = 1 if worker==2
reg earnings after##experimental##married_women, cluster(state)

su delta if experimental==1 & worker==2 & after==1
di `r(mean)'

* Triple diff event study
reg earnings i.year##experimental##married_women, cluster(state)

* A trick to plot the event study
gen 	treated3=0
replace treated3=1 if experimental==1 & married_women==1

reg earnings experimental##married_women year##experimental year##married_women treated3##ib2014.year, cluster(state)

coefplot, keep(1.treated3#*) omitted baselevels cirecast(rcap) ///
    rename(1.treated3#([0-9]+).year = \1, regex) at(_coef) ///
    yline(0, lp(solid)) yline(-5000, lp(dot)) xline(2014.5, lpattern(dash)) ///
    xlab(2010(1)2019)

capture log close
exit
