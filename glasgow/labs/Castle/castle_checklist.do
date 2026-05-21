********************************************************************************
* name: cheng_hoekstra.do
* description: Various Difference-in-Differences Estimators with Cheng and 
* Hoekstra dataset.
********************************************************************************


use "https://github.com/scunning1975/mixtape/raw/master/castle.dta", clear


* Step 1: Write down the target parameter as potential outcomes, population and weights

* Step 2: Make a table of treated units (states by cohort)

* Step 3: Plot the rollout with panelview

* Step 4: Plot the outcome by cohort

* Step 5: Pick the covariates using outcome regression and propensity score reasoning

* Step 6: Estimate and inspect the propensity score

logit treat age gpa
predict pscore
label variable pscore "Propensity score"
	
twoway (histogram pscore if treat==1,  color(red)) ///
       (histogram pscore if treat==0,  ///
	   fcolor(none) lcolor(black)), legend(order(1 "Treated" 2 "Not treated" ))
	   
* Step 7: Estimate the Callaway and Sant'Anna estimator

* Step 8: Event studies

	   
	   
