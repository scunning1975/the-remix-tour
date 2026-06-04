# Hypothesis DAG

## H01 — National suicide-prevention strategies reduced suicide
Status: **complicated**
The headline policy claim. Across European adopters (1994-2010), did adopting a national
strategy lower the suicide rate relative to the counterfactual?

### H01a — Parallel trends hold under the correct (long-difference) baseline
Status: **confirmed** (2026-06-04)
With the universal g-1 baseline, the joint pre-trend test does not reject (sum z^2 = 9.6, df 8, p≈0.30).
(Caveat: low power — only 4 treated countries.)

### H01b — The positive post-adoption association is a causal effect of the policy
Status: **rejected** (2026-06-04)
Estimate is +2.7/100k but cannot be signed (Rambachan-Roth), is indistinguishable from a placebo
(p=0.25), halves when post-communist controls are dropped, and loads on the 2008 recession.

### H01c — TWFE is badly biased by negative weighting here
Status: **rejected** (2026-06-04)
Goodman-Bacon: the "forbidden" already-treated comparisons carry only ~3% weight; TWFE (3.11) ≈ CS (2.7).
The problem is identification, not the estimator.
