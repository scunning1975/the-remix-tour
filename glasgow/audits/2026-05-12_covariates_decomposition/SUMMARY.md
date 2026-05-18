# Audit Summary — Covariates.tex vs 02-Covariates.tex
**Date:** 2026-05-12 (post-Day-1 review)
**Question:** Does the Glasgow `covariates.tex` faithfully reproduce the full TWFE-with-additive-covariates decomposition from Scott's CI-2 `02-Covariates.tex`?

## Three-auditor consensus

**Math: faithful.** All 7 steps of the decomposition are present in `covariates.tex` (frames L2-F2b through L2-F2h). Every equation matches:
- TWFE-with-X model
- Conditional PT imputation identity
- Switching-equation substitution (both Y¹ and Y⁰ carry the same θ)
- θ₁/θ₂ split → ATT = δ + (θ₁ − θ₂)X
- Four cell means under common θ
- DiD on cell means: δ^DD = δ + θ[(X₁₁ − X₁₀) − (X₀₁ − X₀₀)]
- Y⁰-trends-don't-depend-on-X interpretation

**Pedagogy: faithful.** The "Y⁰ evolution is the same regardless of X" framing (Scott's favorite) is preserved verbatim and *enhanced* with sex/income/age examples (original had only rich/poor).

## One real deviation (fixed)

All three auditors flagged that the original numbered the assumptions explicitly: "Assumption 4 (homogeneity)", "Assumptions 5 & 6 (parallel X-trends, treated & control)", with the punchline "without these six, in general TWFE-with-X will not identify the ATT."

The new deck had moved to a tag-style ("(homogeneity)", "(parallel X-trends)") which lost the 1-6 anchoring.

**Fix applied (2026-05-12):**
- L2-F2e title now reads "**Assumption 4**: homogeneous τ in X"
- L2-F2h title now reads "**Assumptions 5 & 6**: Y⁰ trends don't depend on X"
- Closing warmgray line restored: "Without these six assumptions (1-3 baseline DiD plus 4, 5, 6), in general TWFE-with-X does not identify the ATT."

## Files reviewed
- `/Users/scunning/Causal-Inference-2/Slides/Tex/02-Covariates.tex` (lines 645-810)
- `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex` (lines 215-381)

See `audit_1.md`, `audit_2.md`, `audit_3.md` for the three independent audit reports.

## Status: RESOLVED
