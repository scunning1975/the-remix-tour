# Simulations

These are pedagogical simulations Scott uses to teach difference-in-differences. Each one is built to a specific style commitment, which is worth naming up front.

## Who these are for

**A student who doesn't know how to code, but knows enough.**

Specifically: a first- or second-year PhD student who has seen Stata, can run a `reg` command, can make a graph, but has never written a Monte Carlo. They can edit code if shown how. They struggle when code is dense or abstract. They learn fastest when the code reads like a recipe.

These simulations are *teaching tools first, code second*. Performance, conciseness, and DRY-ness are explicitly not the priority. **Readability and traceability are.**

## The style commitments

Every file in this folder follows these rules. If a file breaks one, the file is the problem.

### 1. Repetition over abstraction

Where a programmer would write a loop, we write the lines out. Compare:

```stata
* What a programmer writes
forvalues y = 1/30 {
    replace year = 1979 + `y' if year == `y'
}

* What we write
replace year = 1980 if year==1
replace year = 1981 if year==2
replace year = 1982 if year==3
...
replace year = 2009 if year==30
```

The loop is shorter. The 30 explicit lines are *the lesson*. Each is one substitution, one beat. A student watching the screen can stop at any line and the answer is obvious.

### 2. Block-copy instead of function

Where another programmer would extract a function, we paste the block. ATT(1986, 1986), ATT(1986, 1987), ATT(1986, 1988) each get the SAME ~30 lines with one number changed. Six copies of a recipe with one ingredient swapped tells the student *this is the recipe, applied here, then here, then here*. One function call tells them nothing.

### 3. One step per line

No compound generation. Each `gen` does one thing.

```stata
* What a programmer writes
gen y = baseline + state_trend * year_diff + group_trend * year_diff + e

* What we write
gen y0 = baseline + state_trend * year_diff + group_trend * year_diff
* (and then later, separately:)
gen error = rnormal(0, 1500)
replace y0 = y0 + error
```

Each `gen` or `replace` is one move in the lecture.

### 4. Variable names you'd say out loud

`avg_wage_ame`, `att_11`, `att_10`, `pg1_1991`, `y0_pre`. Not `mu_treated_post` or `pi_hat_g_t`. The names match the labels Scott uses *verbally* — so a student transcribing the code transcribes the speech.

### 5. Comments document the LESSON, not the syntax

```stata
* What a programmer writes
* Generate dummies for each value of time_til
ta time_til, gen(dd)

* What we write
* Sun and Abraham event study commentary: leads and lags
ta time_til, gen(dd)
```

Comments are *paragraph headers* for the lecture, not annotations of what each command does. Stata commands are self-documenting; the LESSON the line is for is not.

### 6. Locals and scalars are for storage, not control flow

`local truth = r(mean)` is fine — we're holding a number to display later. Using `local` to abstract a normalization or selection condition is not. The computation stays inline and visible.

### 7. Display the result

Every meaningful computation ends with `display "ATT estimate = " r(mean)` or similar. A student running this live needs to *see the answer printed*. Silent computation is invisible computation.

### 8. Section banners with `*` and asterisks

```stata
**********************************************************************
* What this section does — one paragraph, in plain English
**********************************************************************
```

These banners are how the file reads as a lecture outline. A student should be able to read just the banners and recover the lesson plan.

### 9. Monte Carlo wrappers are the one allowed abstraction

A Monte Carlo genuinely needs a `program define` block and a `simulate` call — there's no way to write 10,000 explicit replications inline. So commitments 1, 2, and 6 are *suspended for the wrapper*. But the DGP *inside* the wrapper still follows commitments 1–8: explicit `gen` lines, named variables, banner comments, displayed truth. Think of the wrapper as scaffolding around a DGP that is itself fully transparent.

### 10. End with the truth-vs-estimate comparison

Every simulation closes with a block that prints the truth from the DGP and the estimate(s) from each method, side by side. This is the payoff:

```stata
display "True ATT in the post period = " truth
display ""
display "Naive DiD            --- BIASED"
display "DiD with additive X  --- STILL BIASED"
display "OR-DiD               --- close, if outcome model is right"
display "IPW-DiD              --- close, if propensity score is right"
display "DR-DiD               --- closest, only need ONE model right"
```

A student running the file live sees: *truth was X, this method got Y, this one got Z.* That comparison is the whole point of the exercise. Don't end the file with the last `regress`; end it with the verdict.

## What's in here

### `basics/`
- **`na.do`** — illustrates a *no anticipation* violation. Two `post` indicators (correct and shifted-by-one-year). Two treatment-effect patterns (constant and dynamic). Shows how the DiD coefficient changes when NA fails.

### `event_studies/`
- **`title_x_event_study.do`** — conditional parallel trends. Urban vs. rural counties have different baseline trends; treatment is imbalanced toward urban. CSDID with and without urban as a covariate. Demonstrates why conditional PT matters.

### `triple_diff/`
- **`ddd2.do`** — potential-outcomes-based triple-difference simulation. Two biased DiDs (married women vs. married women in different states; married women vs. men+older women within experimental states) and one unbiased DDD. Plots all three event studies on one figure. True ATT = −\$5,000.

### `covariates/`
- **`selection.do`** — Monte Carlo (1,000 reps) comparing CSDID estimates to true ATTs under three selection mechanisms (selection on fixed effects, anticipation, expected benefits). Outputs a LaTeX comparison table.
- **`comparing_did.do`** — heterogeneous treatment effects in X + covariate imbalance + a covariate-driven post-period trend. Compares naive DiD, DiD-with-additive-X, OR-DiD, IPW-DiD, and DR-DiD. Shows which estimators recover the ATT and which don't.
- **`covariates_monte_carlo.do`** and **`covariates_monte_carlo.R`** — Sant'Anna's 4-DGP Monte Carlo (10,000 reps). Compares TWFE, OR, IPW, DR on Bias / RMSE / SE / Coverage / CI length. Generates `mc_dr_1.png` and `mc_dr_2.png`.

### `staggered/`
- **`baker.do`** — staggered adoption with heterogeneous treatment effects over time. Generates 1,000 firms across 4 cohorts (1986, 1992, 1998, 2004). Shows TWFE bias, Sun-Abraham event study, Bacon decomposition, and a step-by-step Callaway-Sant'Anna hand calculation of ATT(g,t).

## How to use them in class

Walk through the DGP first (showing the algebra). Run the code live. Show the output. Ask the audience: *did the estimator recover the truth?*

The point is always the comparison between estimator and the truth, where the truth is something we wrote down in the DGP.

When live coding isn't possible, show the code on the slide. Walk through it line by line. Students take the `.do` file home and run it themselves — that's the homework's hidden reward.

## R versions

Some files have R counterparts (`.R` suffix). Same DGP, same beats, idiomatic R syntax (base R, not tidy abstractions). The R style commitments are the same: explicit steps, no `purrr::map`, comments documenting the lesson.
