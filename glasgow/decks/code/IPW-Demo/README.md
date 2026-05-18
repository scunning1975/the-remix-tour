# IPW Demo — Two Ways to Use a Propensity Score (and Only One Recovers the ATT)

This lab illustrates why **regression with an additive propensity score is not the same as inverse probability weighting** — even though they're often confused. The demonstration is a Monte Carlo simulation (500 runs) under heterogeneous treatment effects.

## What's compared

| Method | What it does | Recovers ATT? |
|---|---|---|
| **A. IPW reweighting controls** | Weight observations by `p(X)/(1−p(X))` for controls; compute ATT from reweighted means. | **Yes** — flexible, recovers ATT even with heterogeneous effects. |
| **B. Regression with additive PS** | `lm(Y ~ D + p_hat)`. Collapses multi-dim covariates into a single scalar; imposes homogeneous treatment effects implicitly. | **No** — biased under heterogeneity. |
| **C. Naive OLS** | `lm(Y ~ D)`. No adjustment. Shown for context. | **No** — confounded. |

## The design

- 1,000 units per simulation, 500 replications
- `X1, X2 ~ N(0, 1)` — covariates
- Selection: `p(X) = inv-logit(0.5·X1 + 0.3·X2 − 0.2)`
- Heterogeneous treatment effect: `τ(X) = 1 + 0.5·X1`
- Outcome: `Y = D·Y(1) + (1−D)·Y(0)` with `Y(0) = X1 + 0.5·X2 + ε`

Method A weights controls correctly, recovering the true ATT.
Method B regresses Y on D and a scalar p̂. Because the regression has no `D × X` interaction, it cannot recover the heterogeneous component of `τ(X)` — even though it adjusts for confounding on average.

## To run

```sh
Rscript ipw_simulation.R
```

Output:
- Console summary (mean, bias, RMSE, SD for each method)
- `figures/ipw_comparison.pdf` — histograms of `estimate − true ATT` for all three methods

## Pedagogical point

Method B looks like it should work — you're "controlling for" the propensity score. But the propensity score is a function of `X`, and collapsing `X` to a scalar throws away exactly the information needed to recover heterogeneous treatment effects. The regression imposes homogeneity by construction, then fails to recover the heterogeneous ATT.

The fix: don't use the propensity score *as a regressor* — use it as a *weight*. IPW gives every treated unit equal weight and reweights controls to look like the treated. That preserves the joint distribution of treatment effects.

## When to teach this

Day 2 of the Glasgow mini-course, in the covariates lesson. After introducing IPW formally, run this simulation live (~30 seconds) and show the figure.
