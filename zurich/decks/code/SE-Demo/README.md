# SE Demo — Why Standard Errors Matter More Than You Think

This folder has **two** things — a static Monte Carlo and an interactive Shiny app — both demonstrating the Bertrand-Duflo-Mullainathan (QJE 2004) result: when panel errors are serially correlated within state, vanilla and robust standard errors *both* over-reject the null massively. Only cluster-robust SEs get the size right.

| File | What it is |
|---|---|
| `se_simulation.R` | Static one-shot Monte Carlo at fixed ρ = 0.7. Console summary + figure. |
| `app.R` | Shiny app. Sliders for ρ, n_states, n_years, n_sim. Watch over-rejection light up in real time. |

To launch the app:
```sh
Rscript -e "shiny::runApp('.', launch.browser = TRUE)"
```
Start with ρ = 0 (all three methods near 5%). Then slide ρ up — the vanilla and HC1 boxes turn red.

## The design

- 40 states, 10 years per state — a standard state-year panel
- Within-state errors are AR(1) with ρ = 0.7
- A placebo treatment is randomly assigned at the state level, mid-panel
- **True effect = 0**
- 500 Monte Carlo replications
- For each replication, estimate β̂ (the point estimate is unbiased) and compute three standard errors:
  1. **Vanilla** (classical OLS, assumes homoskedasticity and independence)
  2. **HC1 robust** (Eicker-Huber-White, Stata's `robust` default)
  3. **Cluster-robust** at the state level (CRVE with HC1 finite-sample correction)
- Form the t-statistic under each SE method; reject H₀ if |t| > 1.96

## Typical output

| Method | Rejection rate (nominal 5%) | Mean SE | True SD(β̂) |
|---|---|---|---|
| Vanilla | ~25% | 0.227 | 0.368 |
| HC1 robust | ~25% | 0.227 | 0.368 |
| Cluster-robust (state) | ~2–5% | 0.421 | 0.368 |

**Vanilla and HC1 over-reject by a factor of 5.** They're identical here because the data-generating process has no heteroskedasticity — only within-state serial correlation, which neither method addresses.

## Pedagogical points

1. **The point estimate is unbiased.** The β̂ converges to zero (the true effect) across replications. The problem is not the point estimate.
2. **Vanilla SE and HC1 are equivalent here.** "Robust" only protects you against heteroskedasticity. If your problem is within-cluster correlation, robust does nothing.
3. **Cluster-robust SE accounts for within-state correlation.** It groups residuals by cluster, sums scores within each cluster, then squares. The cross-terms are what capture the correlation.
4. **Over-rejection is unbiased but inflated.** You'll get a falsely "significant" result a quarter of the time when the truth is zero. That's the BDM warning, replicated.

## To run

```sh
Rscript se_simulation.R
```

Output:
- Console summary (rejection rates, mean SEs)
- `figures/se_sampling_distributions.pdf` — three histograms of the t-statistic, faceted by SE method, with ±1.96 reference lines

## Reference

Bertrand, M., Duflo, E., & Mullainathan, S. (2004). "How Much Should We Trust Differences-in-Differences Estimates?" *Quarterly Journal of Economics*, 119(1), 249–275.

## When to teach this

Day 1 of the Zurich mini-course, **Lesson 5 — Standard Errors**. Run the simulation live (~10 seconds) and show the figure. Then walk through the worked numerical example from the deck (HC1 = 0.153 vs. CRVE = 0.242 in a 6-observation panel) to make the calculation concrete.
