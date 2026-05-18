# Auditor #2 Report — LaLonde deck and Quarto solutions

## Headline finding
Scott's suspicion is **half right** but the diagnosis needs sharpening. The two estimates ($1,559 for TWFE-with-Post×X and $1,559 for "long-difference with X") are not "the same code run twice and mislabeled" — they are **two different code paths that are mathematically guaranteed to produce identical estimates in a T=2 panel**. The deck and qmd tables list them as two distinct estimators yielding distinct numbers; they are not. They are the same estimator.

## Independently-verified numbers (non-experimental panel, year ∈ {75,78}, X = age, agesq, educ, educsq, marr, nodegree, black, hisp, re74, u74; n_T=185, n_C=15,992)

| Quantity | Verified value |
|---|---|
| Naive DiD (no X), by hand and OLS interaction | **$3,621.23** |
| TWFE with Post×X | **$1,559.24** |
| Long-diff: ΔY ~ ever_treated + X (additive) | **$1,559.24** (identical) |
| Hand-rolled OR (lm on ΔY among controls, predict for treated) | **$1,604.29** |
| Hand-rolled IPW (Abadie 2005) | **$2,018.83** |
| `DRDID::ordid` OR | $1,604.29 (SE 638.72) |
| `DRDID::ipwdid` IPW | $2,018.83 (SE 722.54) |
| `DRDID::drdid` "imp" DR | **$1,958.75** (SE 696.14) |
| `DRDID::drdid` "trad" DR | $1,913.02 (SE 723.71) |

Experimental panel (sanity check): Y_T_75=1532.06, Y_T_78=6349.14, Y_C_75=1266.91, Y_C_78=4554.80, post-diff=$1,794.34, DiD=$1,529.20, β74=−$276.60. **Matches deck/qmd.**

## Are TWFE-Post×X and long-diff-with-X distinct? No.
With two periods, demeaning by unit FE and year FE reduces to first-differencing. The Post×X interactions become X·1 in the differenced equation (X is time-invariant here, so ΔX=0 means time-invariant covariates only appear via their Post-interaction). So TWFE on `re ~ D:post + Σ Xk:post | id + year` is **algebraically identical** to `lm(ΔY ~ D + X)`. Difference is 1e-10. The parent agent's table presents these as two distinct entries — which is misleading at best, wrong at worst.

## Bugs to fix (file:line)

1. **`/Users/scunning/the-remix-tour/glasgow/decks/lalonde.tex:668–669`** — Listing TWFE-Post×X and "Long-difference with X" as separate rows. They are the same estimator. Fix: drop one row, or change "Long-difference with $X$" to mean OR (which IS the long-diff with X fit on controls only, then imputed). Better: collapse to one row "TWFE with Post×X ≡ Long-diff w/ X".

2. **`lalonde.tex:670–672`** — Reports OR ≈ $1,500, IPW ≈ $1,600, DR ≈ $1,700. Actual values are OR=$1,604, IPW=$2,019, DR=$1,959 (improved). The OR claim is essentially right (rounded down). **IPW is $400 off** ($1,600 → $2,019 actual). **DR is $260 off** ($1,700 → $1,959 actual). The narrative "DR lands closest to $1,794" is wrong: OR ($1,604) is closest at $190 distance; DR is $165 from benchmark, very close; IPW is $225 over.

3. **`lalonde_r.qmd:303–310`, `lalonde_stata.qmd:280–287`, `lalonde_python.qmd:304–311`** — Same table, same wrong values. Comment lines `# Expect ATT ~ +1,700` for DR and `IPW ATT ≈ +1600` are wrong.

4. **`lalonde_stata.qmd:275`** — Claims `DR ATT = +1529 ← lands at the RCT benchmark`. The actual Stata `drdid` value is ~$1,913 (trad) or ~$1,959 (imp). $1,529 is the **experimental panel DiD** — the parent agent appears to have hallucinated a number from the experimental sample.

5. **`lalonde_python.qmd:296–297`** — Says `DR ATT (simplified): ... Expect ATT ~ +1,700`. The hand-rolled "simplified DR" in the file isn't the Sant'Anna-Zhao IF-based estimator and won't reproduce the canonical number. The expectation comment is wrong.

6. **Discussion-question framing across all three qmds**: "Drop the Post × X interactions … what happens, and why?" — answer would be the FE sweeps them out and you get the plain TWFE = naive DiD = $3,621. This is currently presented correctly, but the framing of TWFE-Post×X as distinct from long-diff-w/-X (and as a "panel" trick) needs honest treatment.

## Experimental vs non-experimental confusion
- The experimental DiD ($1,529) appears in `lalonde_stata.qmd:275` as the **non-experimental** DR-DiD value. That is the smoking-gun copy-paste error.
- Elsewhere, exp/non-exp are kept straight.

## Recommended corrections (numerical)
- Naive DiD: $3,621 ✓
- TWFE-Post×X ≡ Long-diff-w/-X: $1,559 (one row, not two)
- OR (HIT): $1,604
- IPW (Abadie): $2,019
- DR-DiD (Sant'Anna-Zhao imp): $1,959 (SE 696)
- RCT benchmark: $1,794 ✓
- Closest to benchmark: OR at –$190, then DR at +$165, then TWFE/long-diff at –$235, then IPW at +$225.
