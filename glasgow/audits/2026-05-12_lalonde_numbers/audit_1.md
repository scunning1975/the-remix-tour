# Auditor #1 Report — LaLonde Lab (Day 1 + Day 2 covariates)

## Bottom line

- **Part A (experimental)** uses `lalonde_exp_panel.dta` correctly. All Part-A numbers in the deck and the three qmds reproduce exactly.
- **Part B (non-experimental)** uses `lalonde_nonexp_panel.dta` correctly. No data mix-up. But three of the six numbers in the comparison table are wrong, and the deck mis-frames TWFE-with-Post×X and Long-diff-with-X as two independent estimators when they are algebraically the same thing.

## Verified Part A (experimental) numbers — all correct

Replicated against `/Users/scunning/the-remix-tour/glasgow/labs/Lalonde/lalonde_exp_panel.dta`:

| Quantity | Claim | Replicated | Status |
|---|---|---|---|
| $\bar Y^T_{74}$ | $2{,}096 | 2096.17 | ok |
| $\bar Y^T_{75}$ | $1{,}532 | 1532.06 | ok |
| $\bar Y^T_{78}$ | $6{,}349 | 6349.14 | ok |
| $\bar Y^C_{75}$ | $1{,}267 | 1266.91 | ok |
| $\bar Y^C_{78}$ | $4{,}555 | 4554.80 | ok |
| Post diff (78) | $1{,}794 | 1794.34 | ok |
| DiD (78 vs 75) | $1{,}529 | 1529.20 | ok |
| β_74 (placebo) | −$277 | −276.60 | ok |
| β_78 (event study) | $1{,}529 | 1529.20 | ok |

Confirms Scott's CI-2 original solution (`Solutions-Stata.md`).

## Verified Part B (non-experimental) numbers

| Estimator | Deck/qmd claim | Replicated | Status |
|---|---|---|---|
| Naive DiD (no X) | +$3,621 | **+3621.23** | ok |
| Post-period diff (78) | −$8,498 (in deck p.18) | −8497.52 | ok |
| TWFE with Post × X | +$1,559 | **+1559.24** | numerically right |
| Long-diff with X | +$1,559 | **+1559.24** | numerically right, but mis-framed |
| OR (HIT 1997) | ~+$1,500 | **+1604.29** | off by ~$100; should be reported as ~$1,600 |
| IPW (Abadie 2005) | ~+$1,600 | **+2018.83** | **wrong** — off by ~$420 |
| DR-DiD (S&Z imp) | ~+$1,700 | **+1958.75** | **wrong** — off by ~$260; not the "closest" |
| DR-DiD (trad) | — | +1913.02 | for reference |

For comparison, Scott's CI-2 `drdid ... all` Stata output (Solutions-Stata.md lines 444–450) on **the same data, same covariates as the qmds (`age, agesq, educ, educsq, marr, nodegree, black, hisp, re74, u74`)** gives: dripw = $1,979, drimp = $2,033, reg = $1,770, ipw = $1,861. None of those is $1,700.

## The TWFE-vs-Long-diff identity (Scott's suspicion confirmed)

TWFE with `ever_treated:post + (X_k:post)` and unit + year FE on a balanced 2-period panel is **algebraically identical** to OLS of $\Delta Y_i$ on `ever_treated + X_k` (the long-difference with X). They both equal $1559.2436$ to 4 decimals because they are the same regression after the Frisch-Waugh demean. The deck (slide 7, lines 668–669) and all three qmds present them as two independent rows in a "rescue the ATT" table. They are not two estimators. **This double-counts an entry in the comparison table.**

## Specific fixes needed

1. `/Users/scunning/the-remix-tour/glasgow/decks/lalonde.tex`, line 669: drop the separate "Long-difference with $X$" row, or replace with a genuinely distinct estimator (e.g., long-diff *without* X-by-treated interaction). The identity is mechanical.
2. `lalonde.tex` line 670: change "Outcome Regression ≈ +$1,500" → +$1,604.
3. `lalonde.tex` line 671: change "IPW ≈ +$1,600" → +$2,019.
4. `lalonde.tex` line 672: change "DR-DiD ≈ +$1,700, closest" → +$1,959 (and DR is NOT the closest; OR at $1,604 is closer to the $1,794 benchmark). The narrative "DR lands closest" (line 707) is wrong on this dataset.
5. Same three corrections needed in `lalonde_r.qmd` (lines 307–310), `lalonde_stata.qmd` (lines 282–286), `lalonde_python.qmd` (lines 306–310).
6. `lalonde_stata.qmd` line 275 comment "DR ATT = +1529 ← lands at the RCT benchmark" is wrong. Truth from Stata `drdid all`: ATT ≈ $1,900–$2,000 range.

## Verdict

Part A is clean. Part B has the right data and the right naive-DiD, but the Post×X / long-diff identity is mis-presented, and the OR/IPW/DR numbers in the headline comparison table are loosely approximate to flat-wrong, with the "DR is closest" punchline reversed. The truth is DR overshoots and the simple OR is the closest of the four covariate methods on this sample.
