* selection.do
clear all
capture log close
set seed 12345

********************************************************************************
* Define dgp
********************************************************************************
cap program drop dgp
program define dgp, rclass
    clear
	quietly set obs 1000
    gen id = _n

    // Time-invariant characteristics (alpha_i) - fixed effects
    gen 	alpha = rnormal(0, 1)

	// Covariate
	gen 	x  = runiform(0,100)

    // Generate years
    quietly expand 2
    bysort id: gen year = _n
    replace year = 1989 + year

    // Generate time-varying shocks (epsilon_it)
    gen 	epsilon_1 = rnormal(0, 1) if year==1990
    gen 	epsilon_2 = rnormal(0, 1) if year==1991

    // Base potential outcome for untreated state (Y0) with covariate-specific trends
    gen 	y0 = 1000 + 100 + 50*x + 300*epsilon_1 if year==1990
    replace	y0 = 1000 + 200 + 75*x + 300*epsilon_2 if year==1991

    // Generate Y1 with heterogeneous treatment effects
    gen 	y1 = y0
    replace y1 = y0 + 1000 + 100*x if year == 1991

    // Calculate individual treatment effect
    gen 	delta_1 = y1 - y0 if year==1990
	gen 	delta_2 = y1 - y0 if year==1991

    // 1. Selection on fixed effects (alpha_i)
    gen 	treat_fe = (alpha > 0)
    gen 	treat_date_fe = 0
    replace treat_date_fe = 1991 if treat_fe == 1
    gen 	sales_fe = y0
    replace sales_fe = y1 if year == 1991 & treat_fe == 1

    // 2. Selection on anticipated future shocks (epsilon_i2)
    bysort id: egen anticipated_shock = mean(epsilon_2)
    gen treat_anticipation = (anticipated_shock > 0.5)

    // 3. Selection on expected benefits
    bysort id: egen expected_benefit = mean(delta_2)
    sum expected_benefit
    gen treat_benefit = (expected_benefit > r(mean))

    // Generate treatment dates and observed outcomes
    foreach type in  anticipation benefit {
        gen treat_date_`type' = 0
        replace treat_date_`type' = 1991 if treat_`type' == 1
        gen sales_`type' = y0
        replace sales_`type' = y1 if year == 1991 & treat_`type' == 1
	}
end

********************************************************************************
* Monte-carlo simulation
********************************************************************************
cap program drop simulation
program define simulation, rclass
    clear
	quietly dgp

    // Fixed Effects Selection
    qui csdid sales_fe, ivar(id) time(year) gvar(treat_date_fe) notyet
    qui estat simple
    matrix b = e(b)
    return scalar csdid_att_fe = b[1,1]
	su delta_2 if treat_fe==1 & year>=1991
	return scalar att_fe = r(mean)

    // Anticipation Selection
    qui csdid sales_anticipation, ivar(id) time(year) gvar(treat_date_anticipation) notyet
    qui estat simple
    matrix b = e(b)
    return scalar csdid_att_anticipation = b[1,1]
    su delta_2 if treat_anticipation==1 & year>=1991
	return scalar att_anticipation = r(mean)

    // Expected Benefits Selection
    qui csdid sales_benefit, ivar(id) time(year) gvar(treat_date_benefit) notyet
    qui estat simple
    matrix b = e(b)
    return scalar csdid_att_benefit = b[1,1]
	su delta_2 if treat_benefit==1 & year>=1991
	return scalar att_benefit = r(mean)
end

// Run simulation
simulate att_fe = r(att_fe) ///
         att_anticipation = r(att_anticipation) ///
         att_benefit = r(att_benefit) ///
         csdid_att_fe = r(csdid_att_fe) ///
         csdid_att_anticipation = r(csdid_att_anticipation) ///
         csdid_att_benefit = r(csdid_att_benefit), ///
         reps(1000) seed(12345): simulation

// Summarize results
sum

// Store results
save ./selection_csdid.dta, replace

********************************************************************************
* Plot results
********************************************************************************
use ./selection_csdid.dta, clear

// Calculate means and standard deviations
matrix results = J(6, 2, .)
local row = 1
foreach var in att_fe att_anticipation att_benefit csdid_att_fe csdid_att_anticipation csdid_att_benefit {
    quietly summarize `var'
    matrix results[`row', 1] = r(mean)
    matrix results[`row', 2] = r(sd)
    local row = `row' + 1
}

// Generate LaTeX table
file open mytable using "./selection_table.tex", write replace
file write mytable "\begin{table}[htbp]" _n
file write mytable "\centering" _n
file write mytable "\caption{Comparison of CSDID Estimates and True ATTs Across Selection Mechanisms}" _n
file write mytable "\begin{tabular}{lccc}" _n
file write mytable "\toprule" _n
file write mytable " & Selection on & Selection on & Selection on \\" _n
file write mytable " & Fixed Effects & Anticipation & Benefits \\" _n
file write mytable "\midrule" _n
file write mytable "DiD coefficient & " %9.3f (results[4,1]) " & " %9.3f (results[5,1]) " & " %9.3f (results[6,1]) " \\" _n
file write mytable " & (" %9.3f (results[4,2]) ") & (" %9.3f (results[5,2]) ") & (" %9.3f (results[6,2]) ") \\" _n
file write mytable "\midrule" _n
file write mytable "ATT & " %9.3f (results[1,1]) " & " %9.3f (results[2,1]) " & " %9.3f (results[3,1]) " \\" _n
file write mytable "\bottomrule" _n
file write mytable "\end{tabular}" _n
file write mytable "\caption*{\small Note: Each column represents a separate selection mechanism. The first is selection on fixed effects, the second is selection on anticipation, and the third is selection on treatment effects. Note that since different units have different treatment effects, the ATT necessarily changes across each selection device. We estimated this using CSDID controlling for covariates.}" _n
file write mytable "\end{table}" _n
file close mytable
