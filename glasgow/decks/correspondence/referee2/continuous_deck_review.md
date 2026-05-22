# Referee 2 — Continuous DiD Deck Review

**Target:** `/Users/scunning/the-remix-tour/glasgow/decks/continuous.tex` (56-page PDF)
**Scope:** cognitive density, footer collisions, label/object collisions in figures
**Date:** 2026-05-22

---

## Executive summary

The deck reads cleanly conceptually — one idea per slide is the norm, the bullet groups are mostly tight. The dominant problem is **footer overflow on prose-heavy content slides**: `\meta{}` and `\highlight{}` lines repeatedly land on top of, behind, or through the green footer rule. LaTeX emits no warning because `remix.sty` draws the footer via `\setbeamertemplate{footline}`, not as a reserved vbox. I count 18 slides with footer pressure, 7 of them severe (text physically sliced through the rule). A second issue is a cluster of label-on-label collisions in the imported PNG figures around the level/scaled-level weights and one aspirin chart. Verdict: **Minor Revision** — the fixes are mechanical (shrink top vspace, drop a `\vspace{-0.3cm}` before the closing meta line, or move 1–2 captions above the figure) and the figure label problems are localized to ~5 PNGs.

---

## Flagged slides

| # | Title | Category | Issue |
|---|-------|----------|-------|
| 5 | New work says: β^twfe does not have a clean causal reading | footer | Highlight line "WTO/Lu-Yu (2015) data" sliced through footer rule (collides with "The Remix · Glasgow") |
| 9 | China's WTO accession: 155 industries | footer | Caption second line crashes into footer text |
| 10 | One coefficient β^twfe carries the entire dose response | footer | Highlight line "is supposed to answer all three at once. It cannot." sliced through footer rule |
| 11 | Imagine β^twfe as a weighted average | footer | Final highlight line "numbers and different shapes." sliced through footer rule |
| 13 | Ingredient 1: E[D] anchors every formula | content | Figure label reads "E[D] = 0.164" but caption text says "≈ 7.1%"; unit mismatch between body and figure (tariff fraction vs percent) — not flagged for layout, flagged for cross-figure consistency since slide 8 also reports −0.322 "per percentage point" |
| 14 | Ingredient 2: Var(D) sets the scale | footer | Second line of caption "scale things down." crowds footer |
| 16 | Ingredient 4: P(D ≥ l) | figure | Label "P(D >= E[D]) ~ 0.48" sits ~1mm from the red dot marker |
| 17 | Ingredient 5: E[D \| D ≥ l] tracks the upper tail | footer + figure | 2-line caption crowds footer; in-figure "E[D] = 0.164" label overlaps the orange dashed line |
| 19 | Weight #1: the level weight | figure + footer | "sign flip at E[D]" label clips top of plot frame; "positive above mean" sits inside data region with <0.3cm whitespace to curve; 2-line caption crowds footer |
| 20 | Weight #2: scaled-level weight | figure | "still flips at E[D]" and "positive above mean" labels overlap each other inside the chart |
| 21 | Weight #3: the ACRT weight | figure + footer | "dose density (rescaled)" label sits on top of the teal weight curve; 2-line caption crowds footer |
| 22 | Weight #4: the 2×2 weight | figure | Diagonal label "h = l" almost touches the dashed line; legend box overlaps faintly with heatmap cells; 2-line caption crowds footer |
| 23 | Same dose distribution, four different stories | footer | 2-line caption crowds footer |
| 27 | Dosage parameters give us a multitude of ATTs | footer | SEVERE — meta italic line "This is a function of d…" sliced fully through footer rule, second line "dose-response curve." appears BELOW the rule |
| 30 | Moving along the dosage is *not* the ATT | footer | 2-line caption crowds footer |
| 31 | The Average Causal Response — ACRT | footer | SEVERE — Angrist & Imbens meta line sliced through footer rule, overlapping with "The Remix · Glasgow · May 2026" text |
| 33 | Two different parameters, two different questions | figure | ATT(50\|a) and ATT(50\|b) labels collide near the "Selection Bias" dashed line cluster |
| 36 | Why strong PT is stronger: a thought experiment | footer | SEVERE — meta line "Randomization of dose gives strong PT automatically…" sliced through footer rule |
| 38 | Discrete: raw outcomes by dose group | footer | 2-line caption second line crowds footer |
| 39 | Discrete: with treatment effects (linear, homogeneous) | footer | 2-line caption second line crowds footer |
| 40 | Discrete: with heterogeneity in the dose response | footer | 2-line caption crowds footer |
| 41 | Discrete: first differences make the comparison visible | footer | 2-line caption crowds footer |
| 42 | Discrete: the implied counterfactual | footer | 2-line caption crowds footer |
| 43 | Discrete: the DiD estimates, dose by dose | footer | 2-line caption crowds footer |
| 48 | Option 2: Bins | footer | 2-line caption "Step-function dose response." second line collides with footer |
| 49 | Pros and cons of bins | density | Two bullet groups (Pros, Cons) plus a highlight line — three groups on one slide; ask reader to hold two unrelated lists. Borderline. |
| 50 | Option 3: Non-parametric smoothing | footer | 2-line caption "confidence bands." second line collides with footer |
| 52 | Pros and cons of non-parametric smoothing | density | Same two-list problem as slide 49 |
| 53 | The WTO example, done properly | footer | SEVERE — caption final word "on." sliced through footer rule |
| 55 | Pre-trends, dose by dose | footer | SEVERE — caption second line "the placebo is large…" sliced through footer rule |
| 56 | Closing: what to do tomorrow | footer | Highlight final line "right is no longer prohibitive." kisses the footer rule |

---

## Diagnoses and fixes

**Footer collisions (slides 5, 9–11, 14, 17, 19, 21–23, 27, 30, 31, 36, 38–43, 48, 50, 53, 55, 56).** The root cause is a recurring two-part pattern: (a) an opening `\vspace{0.4–0.6cm}` at the top of every text slide, then (b) a closing `\highlight{}` or `\meta{}` line whose text is long enough to wrap to two lines. With a 12pt body on a 56pp deck, two-line wrap of the trailing line is what tips content into the footer. **Fix:** for every flagged slide, either (i) remove or halve the opening `\vspace`, (ii) shorten the closing line so it fits on one line, or (iii) for figure slides, move the caption ABOVE the figure (the figure has more vertical slack than the caption does). The seven severe slices (5, 10, 11, 27, 31, 36, 53, 55) need both: trim top vspace AND tighten the bottom text.

**Figure label collisions (slides 16, 17, 19, 20, 21, 22, 33).** These come from the 02_mean.pdf → 10_weight_2x2_heatmap.pdf series and the aspirin acrt_fig2d.png. The labels were placed in absolute coordinates against a fixed plot region but the labels then got pushed by the legend or by an overlapping curve. **Fix:** regenerate those seven figures with `hjust = 0, vjust = -0.5` (or equivalent nudge of 0.3cm) on the affected annotations; for slide 22 specifically, shrink the in-plot legend box to a corner.

**Density (slides 49, 52).** These two "Pros and cons" slides force the audience to read two unrelated bullet groups and then a closing highlight on the same slide. Borderline — the lists are short and the parallelism between Pros/Cons is visual, not cognitive. **Fix is optional**: if you want one-idea-per-slide strictly, split each into two slides; if you keep them, drop the closing highlight (`\highlight{Often the right first cut...}` and `\meta{In practice...}`) — it's a third thought.

**Slide 13 cross-figure consistency.** Earlier text says "Mean dose ≈ 7%" and slide 8 reports −0.322 "per percentage point." Slide 13's figure label reads "E[D] = 0.164" (i.e. the dose was re-parameterized to fraction-of-baseline-tariff units). Not a layout problem but worth a note: pick one parameterization or annotate both.

---

## Verdict

**Minor Revision.** No structural rewrite is needed — the content slides are clean, the figure sequence makes sense, the rhetoric of "one idea per slide" holds across all 56. The fixes are mechanical and localized: tighten 18 trailing prose lines, regenerate 7 figures with nudged labels, optionally split the two Pros/Cons slides. Total: under an hour of work.
