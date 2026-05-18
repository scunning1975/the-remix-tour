# Audit #3 — TWFE-with-covariates decomposition

**Files:** `/Users/scunning/Causal-Inference-2/Slides/Tex/02-Covariates.tex` (lines 644–802) vs. `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex` (lines 215–381, 783–798).

## Step-by-step preservation

| Original frame (CI-2) | Glasgow slide | Status |
|---|---|---|
| Standard TWFE Model (646) | L2 "TWFE-with-controls" (215) + Proof step 1 (235) | Preserved. Eq. 218/239 reproduces $\alpha_1+\alpha_2 T+\alpha_3 D+\delta(T\!\times\!D)+\theta X$ exactly. |
| Decomposing TWFE w/ covariates (669) | Proof step 1 (235) | Imputation identity for $E[Y^0_1|D{=}1,X]$ reproduced verbatim, including the final switching-equation substitution line 249. |
| Switching equation substitution (694) | Proof step 2 (259) | Both expressions match: $E[Y^0_1]=\alpha_1+\alpha_2+\alpha_3+\theta X$ and $E[Y^1_1]=\alpha_1+\alpha_2+\alpha_3+\delta+\theta X$. Glasgow also shows the three observed cell means as an intermediate step — strictly additive, no loss. |
| Collecting terms (713) | Proof step 3 (282) | $\theta_1, \theta_2$ split is identical. ATT$=\delta+(\theta_1-\theta_2)X$ matches. |
| Assumption 4: Homogeneous TE in $X$ (735) | Proof step 4 (303) | Sex and income examples preserved; "age" added. Renamed from "Assumption 4" to just **the assumption** (block titled "homogeneous $\tau$ in $X$"). |
| X-specific trends (750) | Proof step 5 (324) | Four cell means reproduced identically with $X_{11},X_{10},X_{01},X_{00}$. |
| X-specific trends cont. (765) | Proof step 6 (342) | DiD formula identical; $\delta^{DD}=\delta+\theta[(X_{11}-X_{10})-(X_{01}-X_{00})]$ matches algebraically. |
| Assumption 5 and 6 (790) | Proof step 7 (362) | The signature line **"the evolution of $Y^0$ is the same regardless of $X$"** is preserved verbatim in the block (line 366). Rich/poor example kept, men/women + young/old added. |

## Scott's pedagogical favorite

Yes — the line *"the evolution of the untreated potential outcome $Y^0$ over time is the same regardless of $X$"* (line 366) is explicitly present, placed inside a highlighted block. This is the punchline Scott repeatedly cares about. Preserved.

## Naming

"Assumption 4 / 5 / 6" labels are **dropped** as numeric labels but the substance is faithfully retained and re-tagged as `(homogeneity)` and `(parallel $X$-trends)` in the closing caption of step 7 (line 378). The "three more assumptions" framing on the umbrella slide (line 222) replaces the 4/5/6 numeric scheme; it adds an explicit (1) additive functional form, which CI-2 left implicit.

## What CI-2 had that Glasgow changes or omits

- "Why not both?" frame (804) listing OR/IPW/TWFE with assumption-count tally: **not reproduced** in the decomposition block. The equivalent content surfaces later in Lesson 5 (DR-DiD) and the comparison table in Lesson 6 (line 885).
- Glasgow **adds** value: an umbrella slide naming the three hidden assumptions (line 215) and Lesson 6 frame "TWFE-with-controls has two distinct problems" (line 783), which separates the additive-RHS disease from the C&C FE-transformation problem. CI-2 had no equivalent.

## Verdict

**Faithful.** The full 7-step decomposition is reproduced with the same algebra, same conditional expectations, same slope split, same four cell means, same DiD cancellation. Scott's signature interpretation of $Y^0$-evolution is preserved verbatim. Numeric assumption labels (4/5/6) are dropped in favor of named tags, but no pedagogical content is lost; the "Why not both?" comparison is relocated rather than removed.
