# Audit #1 — Covariates Decomposition Fidelity

**Files compared:**
- Original: `/Users/scunning/Causal-Inference-2/Slides/Tex/02-Covariates.tex` (frames 644–802)
- New: `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex` (frames L2-F2 through L2-F2h, lines 214–381)

## Slide-by-slide map

| Original frame | New frame | Status |
|---|---|---|
| Standard TWFE Model (model + "three more assumptions") | L2-F2 | Faithful, expanded |
| Decomposing TWFE w/ covariates (Y^1 expr + conditional PT chain) | L2-F2b | Faithful, compressed |
| Switching equation substitution (Y^0 counterfactual + Y^1) | L2-F2c | Faithful (adds Y0|D=1, Y1|D=0, Y0|D=0 cell expressions) |
| Collecting terms (θ_1, θ_2 → ATT = δ + (θ_1−θ_2)X) | L2-F2d | Faithful, identical algebra |
| Assumption 4: Homogeneous treatment effects in X | L2-F2e | Faithful (adds an age example) |
| X-specific trends (4 cell means) | L2-F2f | Faithful, identical equations |
| X-specific trends (DiD on cells → δ + θ[(X11−X10)−(X01−X00)]) | L2-F2g | Faithful, identical |
| Assumption 5 and 6 (Y(0) doesn't depend on X; rich vs. poor) | L2-F2h | Faithful, expanded |

All 7 derivation steps are present. The 7-frame structure (L2-F2b…F2h) cleanly mirrors the seven derivation frames in the original.

## Equation-by-equation fidelity

- **TWFE specification:** original uses `α_2 T_t + α_3 D_i + δ(T_i × D_t)`. New version uses `α_i + γ_t + δ(T_t × D_i) + θ X` on L2-F2 but restates the dummy form `α_1 + α_2 T_t + α_3 D_i + δ(T_t × D_i) + θ X` on L2-F2b. Acceptable — the dummy form is what the rest of the derivation uses.
- **Conditional PT chain:** original shows 4-line rearrangement; new compresses to 2 lines but lands on identical counterfactual identity. No content lost.
- **θ_1/θ_2 step:** identical algebra; `ATT(X) = δ + (θ_1 − θ_2)X` matches verbatim.
- **Four cell means:** identical.
- **DiD on cells:** identical, `δ^{DD} = δ + θ[(X_11 − X_10) − (X_01 − X_00)]`.

## Framing / numbering

- **Assumption 4 / 5 / 6 numbering is NOT preserved.** Original names them explicitly "Assumption 4," "Assumption 5 and 6." New deck reframes as "three more assumptions" (additivity, homogeneity, parallel X-trends) on L2-F2 and refers to them as "(homogeneity)" and "(parallel X-trends)" on L2-F2h. The new deck never says "Assumption 4/5/6." This is a real change — Scott's original explicitly counts to six total assumptions (1-3 standard + 4-6 covariate). The new deck mentions "three more assumptions" without anchoring to the 1–3 baseline as Assumptions 1–6.
- **"Additive functional form"** is added as an explicit named assumption (L2-F2 item 1). The original does not name it explicitly but treats it as a maintained assumption — this is an improvement, not a deviation.
- **"Y(0) trends don't depend on X" interpretation:** Preserved and elevated (block title on L2-F2h, plus three concrete examples: rich/poor, men/women, old/young). Original gave only the rich/poor line. Scott's favorite framing is intact and enhanced.

## Gaps / concerns

- The new deck loses the explicit "Assumptions 1–6" accounting. A student reading the new deck won't learn that TWFE-with-X needs *six* assumptions in Scott's framework. Consider restoring numbered language on L2-F2 and L2-F2h.
- The original's closing line "Without these six, in general TWFE will not identify ATT" is partially echoed by L2-F2h's "Without both, TWFE-with-$X$ does not identify the ATT" — but "both" refers only to the two covariate assumptions, not all six.

## Bottom line

**Faithful**, with one framing regression: the explicit "Assumptions 4, 5, 6" / six-total-assumptions accounting is dropped in favor of "three more assumptions." All equations, all 7 steps, and the Y(0)-trends-don't-depend-on-X interpretation are intact and in some places improved. Recommend restoring the numbered-assumption language on L2-F2 and L2-F2h.
