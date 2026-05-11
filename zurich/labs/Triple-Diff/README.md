# Triple Differences Lab — Day 2 morning, Zurich Workshop

**Goal:** Take everything from the triple-diff lecture — eight cells, two DiDs, one subtraction — and run it on a real dataset Scott himself worked with.

You'll work with the abortion-and-gonorrhea data from Cunningham & Cornwell (2013), which itself sits in the lineage of Donohue & Levitt's (2001) abortion-and-crime paper. The treatment: state-level access to legal abortion. The treated cohort: Black women aged 15–19, the group whose fertility was most affected by abortion legalization in the early 1970s. The placebo cohort: an older Black-female cohort whose fertility was largely complete by then.

If abortion access changed who was born in the 1970s, then years later the cohort raised after that policy should show different sexually-transmitted-infection rates as teenagers — because the *composition* of the cohort differs. If true, the effect should show up for the 15–19 cohort (treated) but not for older cohorts (placebo).

That's the triple-diff: **(repeal-vs-Roe states) × (early-cohort year vs. late-cohort year) × (treated age group vs. placebo age group).**

---

## Data

Stata file on Scott's GitHub:

```
https://github.com/scunning1975/mixtape/raw/master/abortion.dta
```

In R:
```r
library(haven)
abortion <- read_dta("https://github.com/scunning1975/mixtape/raw/master/abortion.dta")
```

In Stata:
```stata
use "https://github.com/scunning1975/mixtape/raw/master/abortion.dta", clear
```

Variables you'll use:

| Variable | Description |
|---|---|
| `fip` | State FIPS code |
| `year` | Calendar year |
| `repeal` | 1 if state repealed abortion bans before *Roe* (treated state), 0 otherwise |
| `bf15` | Indicator: Black female, 15–19 (treated cohort) |
| `bf25` | Indicator: Black female, 25–29 (placebo cohort) |
| `lnr` | Log gonorrhea rate (outcome) |
| `totpop` | Total population (use as weights) |
| Controls | `acc, ir, pi, alcohol, crack, poverty, income, ur` |

You should look at `abortion.dta` yourself — verify the variable names match what you expect. If something is off, document it.

---

## The 3×2 cube you'll work with

We collapse to a clean 2×2×2 = 8 cells for the manual calculation:

| State group | Cohort | Period | Cell |
|---|---|---|---|
| Repeal | 15–19 (treated) | Pre   | `bf15 = 1, repeal = 1, year ≤ 1985` |
| Repeal | 15–19 (treated) | Post  | `bf15 = 1, repeal = 1, year ≥ 1986` |
| Roe    | 15–19 (treated) | Pre   | `bf15 = 1, repeal = 0, year ≤ 1985` |
| Roe    | 15–19 (treated) | Post  | `bf15 = 1, repeal = 0, year ≥ 1986` |
| Repeal | 25–29 (placebo) | Pre   | `bf25 = 1, repeal = 1, year ≤ 1985` |
| Repeal | 25–29 (placebo) | Post  | `bf25 = 1, repeal = 1, year ≥ 1986` |
| Roe    | 25–29 (placebo) | Pre   | `bf25 = 1, repeal = 0, year ≤ 1985` |
| Roe    | 25–29 (placebo) | Post  | `bf25 = 1, repeal = 0, year ≥ 1986` |

The cutoff at 1985/1986 corresponds to the cohort timing: 15-year-olds in 1986 were born in 1971, so they're the first cohort raised entirely under repeal-state abortion access. (Use weighted means using `totpop` as the weight.)

---

## Part 1 — Calculate the DDD by hand

1. Compute the **eight cell means** of `lnr` (weighted by `totpop`). Show your numbers.

2. Compute the **treated-cohort DiD** (for the 15–19 cohort):
   $$\text{DiD}_{\text{treated}} = \big(\bar Y^{\text{rep}}_{\text{post}} - \bar Y^{\text{rep}}_{\text{pre}}\big) - \big(\bar Y^{\text{Roe}}_{\text{post}} - \bar Y^{\text{Roe}}_{\text{pre}}\big)$$

3. Compute the **placebo DiD** (for the 25–29 cohort):
   $$\text{DiD}_{\text{placebo}} = \big(\bar Y^{\text{rep}}_{\text{post}} - \bar Y^{\text{rep}}_{\text{pre}}\big) - \big(\bar Y^{\text{Roe}}_{\text{post}} - \bar Y^{\text{Roe}}_{\text{pre}}\big)$$

4. Compute the **DDD**:
   $$\widehat{\delta}_{\text{DDD}} = \text{DiD}_{\text{treated}} - \text{DiD}_{\text{placebo}}$$

5. **Interpret.** What sign do you get on the DDD? What does it say about whether abortion legalization affected gonorrhea incidence in the cohort raised under it?

---

## Part 2 — Run the DDD as a regression

Recover the same number using the saturated triple-interaction regression. Stack the treated and placebo cohorts; let `cohort_treated` be `1` for `bf15 == 1` and `0` for `bf25 == 1`; let `post` be `1` for `year >= 1986` and `0` for `year <= 1985`.

### R
```r
library(estimatr)
library(dplyr)

df <- abortion |>
  filter(bf15 == 1 | bf25 == 1, year <= 1990) |>          # narrow window for clarity
  mutate(
    cohort_treated = as.integer(bf15 == 1),
    post           = as.integer(year >= 1986)
  )

# Saturated triple-interaction. The coefficient on the three-way is the DDD.
ddd_fit <- lm_robust(
  lnr ~ repeal * cohort_treated * post,
  data    = df,
  weights = totpop,
  clusters = fip                                          # cluster at state level
)
summary(ddd_fit)
```

### Stata
```stata
keep if (bf15 == 1 | bf25 == 1) & year <= 1990
gen cohort_treated = (bf15 == 1)
gen post           = (year >= 1986)

reg lnr i.repeal##i.cohort_treated##i.post [aw=totpop], cluster(fip)
```

The coefficient on the **three-way interaction** `repeal × cohort_treated × post` is your $\widehat\delta_{\text{DDD}}$. Report it with its clustered SE.

---

## Part 3 — Compare

1. Does the regression coefficient match your hand-computed DDD from Part 1? (It should, to machine precision.)
2. Report the **clustered standard error** (clustered at state, `fip`).
3. How does the SE change if you cluster at the wrong level (e.g., observation)? Try `vcov = "HC1"` instead and compare.
4. **Interpretation in your own words.** What can you conclude about the effect of abortion legalization on the gonorrhea incidence of the cohort raised under it? What can you *not* conclude from this 3×2?

---

## Part 4 — Connect it to Donohue & Levitt

Cunningham & Cornwell (2013) wasn't the first paper to use abortion-as-natural-experiment with a generational lag. Donohue & Levitt (2001) famously argued abortion legalization caused the 1990s crime decline through the same mechanism — fewer unwanted births → fewer high-risk teenagers two decades later.

Write a paragraph: what role does the **placebo cohort** play in this kind of design? If you ran Donohue & Levitt without a placebo cohort, what alternative explanations would survive? What does the triple-diff buy you over their double-diff?

---

## Deliverable

A short writeup (one to two pages):

- The 8 cell means (a small table)
- Your hand-computed DiD-treated, DiD-placebo, and DDD
- Your regression output with clustered SE
- A side-by-side check that the regression DDD = your hand-computed DDD
- A paragraph interpreting the result and one paragraph on the placebo-cohort role

---

## References

- Cunningham, Scott, and Christopher Cornwell (2013). "The Long-Run Effect of Abortion on Sexually Transmitted Infections." *American Law and Economics Review* 15(1): 381–407.
- Donohue, John J., and Steven D. Levitt (2001). "The Impact of Legalized Abortion on Crime." *Quarterly Journal of Economics* 116(2): 379–420.
- Cunningham, *Causal Inference: The Mixtape*, Chapter 9 (Triple Differences section): \
  [mixtape.scunning.com/09-difference\_in\_differences\#triple-differences](https://mixtape.scunning.com/09-difference_in_differences#triple-differences)
