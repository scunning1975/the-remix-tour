# Audit 2 — Covariates Decomposition (TWFE-with-X)

Comparison: `Causal-Inference-2/Slides/Tex/02-Covariates.tex` (lines 645–802) vs. `glasgow/decks/covariates.tex` (frames L2-F2b through L2-F2h, lines 234–381).

## Step-by-step comparison

- **Step 1 — TWFE model + conditional PT identity (F2b).** Faithful. The TWFE specification and the rearrangement E[Y^0_1|D=1,X] = E[Y_0|D=1,X] + E[Y_1|D=0,X] − E[Y_0|D=0,X] match Scott's original (line 688). Compressed from two frames to one but no content lost.
- **Step 2 — Substitute TWFE, slopes look the same (F2c).** Faithful. Yields E[Y^0_1|D=1,X] = α_1+α_2+α_3+θX and E[Y^1_1|D=1,X] = α_1+α_2+α_3+δ+θX. Matches original lines 699 and 705.
- **Step 3 — Let slopes differ; ATT(X)=δ+(θ_1−θ_2)X (F2d).** Faithful. Matches original lines 723–727 exactly; new deck even adds the boxed θ_1, θ_2 highlighting.
- **Step 4 — "What if θ_1≠θ_2?" → Homogeneity assumption (F2e).** Pedagogically faithful (sex/income/age examples preserved, age added) but **NOT labeled "Assumption 4."** Title says "the named assumption: homogeneous τ in X." Original frame title is explicitly "Assumption 4: Homogeneous treatment effects in X."
- **Step 5 — Four cell means under common θ (F2f).** Faithful. The four conditional expectations match original lines 755–758 with the same X_{dt} indexing.
- **Step 6 — DiD of cell means → δ^DD = δ + θ[(X_{11}−X_{10})−(X_{01}−X_{00})] (F2g).** Faithful. Math is identical to original lines 778–781 (and tighter: factored θ outside the bracket). Adds the boxed equal-trends condition, a clean improvement.
- **Step 7 — Y^0-trends-don't-depend-on-X interpretation (F2h).** Interpretively faithful — "evolution of Y^0 is the same regardless of X" is taken directly from the original line 796. Rich/poor example preserved, men/women and old/young added. **BUT not labeled "Assumption 5 and 6."** Both restrictions are collapsed into one frame called "two assumptions, named: (homogeneity) and (parallel X-trends)."

## Assumption numbering

The explicit "4, 5, 6" labels are **gone**. Earlier (F2, line 215) the deck does flag the "three more assumptions" as (1) additive form, (2) homogeneity, (3) no X-specific trends — a renumbering relative to the 1–6 master list. Scott's original line 800 closes with "Without these six, in general TWFE will not identify ATT" — that sentence has no analogue in the new deck. **If Scott wants the 1–6 frame preserved verbatim, this is a deviation.**

## Math verification

ATT(X) = δ + (θ_1 − θ_2)X: correct. Subtracting the two CEFs cancels α_1+α_2+α_3 and leaves δ+(θ_1−θ_2)X. DiD on cell means: correct. All α's cancel pairwise; δ appears only in the (1,1) cell; θ multiplies (X_{11}−X_{10})−(X_{01}−X_{00}). No errors.

## Bottom line

Math and interpretation are faithful and arguably cleaner than the original. The pedagogical arc (TWFE → conditional PT → same-slope surprise → heterogeneity → cell means → DiD → Y^0-trends) is fully preserved across 7 frames as advertised. The one real deviation is the explicit "Assumption 4 / 5 / 6" numbering, which has been replaced by named assumptions ("homogeneity," "parallel X-trends") and a separate (1,2,3) of "three more assumptions" introduced at F2. If Scott values the 1–6 count as a teaching anchor — and his original ends explicitly on "without these six" — restoring the "Assumption 4," "Assumption 5 and 6" labels (one line each, in the block titles of F2e and F2h) would close the only meaningful gap.
