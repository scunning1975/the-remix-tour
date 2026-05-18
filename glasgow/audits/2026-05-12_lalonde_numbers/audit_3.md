# Audit #3 — Lalonde deck & Quarto solutions

## Independently-verified results (R, DRDID, fixest)

### Experimental panel (`lalonde_exp_panel.dta`, n_T = 185, n_C = 260)
- Cell means: Y_T_75 = 1532, Y_T_78 = 6349, Y_C_75 = 1267, Y_C_78 = 4555 ✓
- Post diff-in-means (78): **1794.34** ✓
- DiD (75→78): **1529.20** ✓
- β_74 (placebo): **−276.60** ✓

### Non-experimental panel (`lalonde_nonexp_panel.dta`, n_T = 185, n_C = 15,992)
| Estimator | ATT | Notes |
|---|---|---|
| Naive DiD (75→78, no X) | **3621.23** | |
| TWFE re ~ ever_treated:post + post:X (id+year FE) | **1559.24** | |
| Long-difference Δre ~ ever_treated + X | **1559.24** | |
| OR (HIT 1997; Δre ~ X on controls, impute, mean residual on treated) | **1604.29** | |
| IPW (Abadie 2005; logit p̂(X), w = p̂/(1−p̂)) | **2018.83** | |
| DR-DiD `estMethod="imp"` (no agecube, X as in qmd) | **1958.75** | |
| DR-DiD default (with agecube; matches Scott's published solution) | **2032.92** | |
| RCT benchmark = post-period diff on experimental panel | **1794.34** | |

## TWFE-with-Post×X vs Long-diff-with-X: **should they be equal?** YES.

This is an algebraic identity, not an error. I confirmed every covariate in the non-experimental panel is time-invariant within `id` (max distinct values across the two periods = 1 for every X). When X is time-invariant and the panel has T=2:

- Within-id demeaning removes the time-invariant X levels.
- `post:X` interactions survive demeaning and act as X-loadings on the change.
- The resulting equation is identical to OLS on `Δre = α + γ·ever_treated + Xβ + ε` after also netting out the year FE (which becomes the constant).

So Scott's deck line 668–669 reporting BOTH at **$1,559** is correct and reproducible. Worth a sentence in the deck saying "these are algebraically the same when X is time-invariant in a T=2 panel" — but the numbers are right.

## File-by-file claims audit

### `decks/lalonde.tex`
- Line 269 DiD = $1,529 ✓
- Line 274 post-diff = $1,794 ✓
- Line 349 β_74 = −$277 ✓
- Line 351 β_78 = +$1,529 ✓
- Line 546 naive DiD = $3,621 ✓
- Line 668 TWFE w/ Post×X = $1,559 ✓ (1559.24)
- Line 669 long-diff w/ X = $1,559 ✓ (1559.24, **same by identity**)
- Line 670 OR ≈ $1,500 — my run gives **$1,604**. "≈ $1,500" is plausible but loose; "≈ $1,600" is closer.
- Line 671 IPW ≈ $1,600 — my run gives **$2,019**. **Wrong** — IPW is closer to $2,000, NOT $1,600.
- Line 672 DR ≈ $1,700 — Scott's published CI-2 solution finds **$2,033** (with agecube); without agecube, **$1,959**. "≈ $1,700" is **wrong** — DR is closer to $2,000, not $1,700.

### `labs/Lalonde/lalonde_r.qmd`
- Part A numbers all match (Y values, DiD = 1529, post-diff = 1794, β_74 = −277).
- Line 244 "TWFE expected ≈ +1,559" ✓
- Line 298 "Expect ATT ~ +1,700" for DR — **wrong** (true ≈ $1,959–$2,033).
- Comparison table (lines 303–310) same OR/IPW/DR claims as deck — same errors.

### `labs/Lalonde/lalonde_stata.qmd`
- Part A numbers all match.
- Line 215 "TWFE ≈ +1559" ✓
- Line 236 OR ≈ +1,500 — loose (true 1,604).
- Line 260 IPW ≈ +1,600 — **wrong** (true 2,019).
- Line 275 "DR ATT = +1529" — **wrong**. Stated as if equal to the experimental DiD. Real DR-DiD ≈ $2,033 (Scott's own published solution).
- Same comparison table errors.

### `labs/Lalonde/lalonde_python.qmd`
- Part A numbers all match.
- Line 240 TWFE ≈ +1559 ✓
- Line 297 "Expect ATT ~ +1,700" for DR — **wrong**.
- Same comparison table errors.

## Did the parent agent confuse experimental and non-experimental data?

No clear confusion. Cell means quoted for the experimental panel (1532/6349/1267/4555) match the experimental data, and the non-experimental block correctly uses the non-experimental panel (naive DiD = 3,621 is the non-exp value). The `lalonde-did.R` original solution at lines 192–202 also uses df_exp |> filter(year == 78) for the OLS DIM in the *non-exp* section — that's Scott's own published copy-paste slip and is not in the audited Quarto files.

## Scott's published CI-2 solution (`Solutions/Solutions-R.md`, ground truth)
- Naive DiD (non-exp): **3621.23**
- OLS with linear X (no Post-interaction, with `agecube` and `+ year + ever_treated` FE): post coef = **3522.47**. *Note: this is the linear-X spec in the original — not the Post×X spec the new lab teaches.* Scott's published solution **does not** compute the Heckman OR or Abadie IPW separately on this panel; it goes straight from naive DiD to DRDID.
- DR-DiD (imp, with `re74 + u74`, with `agecube`): **2032.92** (SE 707.48, 95% CI [646, 3420]).

## Bottom line / what to fix

1. **OR / IPW / DR values in the comparison tables are wrong** in all four files. Correct values:
   - OR ≈ **$1,604**
   - IPW ≈ **$2,019**
   - DR-DiD ≈ **$1,959** (matching the qmd's X list) or **$2,033** (with agecube, matching Scott's CI-2 published solution).
2. The TWFE = long-diff = **$1,559** identity is real and reproducible — not a bug. Worth a one-line note that they're algebraically equal when X is time-invariant and T=2.
3. The "DR-DiD lands closest to the RCT benchmark" claim **survives** — DR ≈ $2,033 vs benchmark $1,794, distance $239. But the deck's stated DR value ($1,700, distance −$94) is wrong; the *direction* of overshooting flips.
4. `lalonde_stata.qmd` line 275 ("DR ATT = +1529") is a sharp error — it conflates the experimental DiD with the non-experimental DR estimate.
