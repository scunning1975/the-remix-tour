# Audit #2 — Rhetoric and Tempo of the PO Derivation (slides 5–13 + coda)

## Title-by-title judgment (assertion vs. label)

| Slide | Title | Verdict |
|---|---|---|
| step 5 | "what we actually need: parallel trends on $Y^0$" | **assertion-leaning** — sets the destination. Good. |
| step 6 | "TWFE's structural model for $Y^0$" | **label**. Could assert: "TWFE imposes a single $\beta$ on $Y^0$." |
| step 7 | "take expectations: treated, post" | **label** — pure stage direction. Better: "Treated, post: all four pieces fire." |
| step 8 | "take expectations: treated, pre" | **label**. Better: "Treated, pre: $\alpha_2$ switches off." (Currently buried in the body.) |
| step 9 | "subtract: the treated $Y^0$ trend" | half. Better: "Treated $Y^0$ trend = $\alpha_2 + \beta\,\Delta X^T$." |
| step 10 | "same logic for the control group" | **label**. Better: "Control trend has the same form — only $\Delta X$ changes." |
| step 11 | "apply PT in $Y^0$: set the two trends equal" | half. Better: "PT forces $\beta(\Delta X^T - \Delta X^C) = 0$." |
| step 12 | "two ways for $\beta(\Delta X^T - \Delta X^C) = 0$ to hold" | half. Title states the equation, not the takeaway. Better: "Either $\beta=0$ or $X$ trends match." |
| step 13 | "Assumptions 5 & 6: $Y^0$ trends don't depend on $X$" | **assertion**. Strong. |
| coda | "what if $\beta$ varies over $t$?" | **question**, which is fine as a coda but soft. |

Across steps 1–4 the titles are noticeably more assertive ("the slopes look the same", "what if $Y^1$ and $Y^0$ have different slopes", "**Assumption 4**: homogeneous $\tau$ in $X$"). **Steps 5–13 lose that voice when the algebra starts.** Consistency is broken: the homogeneity proof asserts, the PT proof narrates stage directions.

## Density and pacing

Working: 7, 8, 10, 11 breathe — one equation per slide, real `\vspace`, no list clutter. This is exactly the slow-Scott tempo.

Not working: **step 9 is the densest slide in the block** (two-equation align, subtract directive, boxed result, footnote definition) and it lands right when the audience needs the most room. Step 5 is almost empty; step 9 is almost full. The MB/MC equalization fails here. Split 9 into two: (a) "stack the two", (b) "$\alpha_1,\alpha_3$ cancel — what's left is $\alpha_2 + \beta\Delta X^T$".

Step 12's "Either/Or" blocks plus a centered italic restatement is three beats on one slide. Pick two.

## Color and underbrace

The warmgray cancellation on 9 and 11 **works** — eye follows the cancel. But on 8, "$\alpha_2$ switches off" is graytext in the caption rather than visually striking through an $\alpha_2$ that's there to be cancelled. The cue lands harder when the symbol appears greyed in place. Underbraces on 9 and 11 are load-bearing, not clutter — keep them.

## Coda (slide o)

Lands but lightly. "Post × X interactions" is named without showing what it looks like, and there's no callback to the **\$1,559 TWFE-with-id-FE LaLonde result**. Right now it's a teaser without a hook. Expand to two slides: (1) $\beta_{\text{pre}} \neq \beta_{\text{post}}$ with the rich-get-richer concrete example; (2) "this is the spec that gave \$1,559 — Post × X is how you let $\beta$ move."

## Top 3 fixes, ranked

1. **Rewrite titles 6–12 as assertions** to match the voice of steps 1–4. Especially 7, 8, 10 (currently pure stage direction).
2. **Split step 9** into two slides. It's the one density spike in an otherwise patient sequence and it lands at the cancellation moment, which is exactly where Scott teaches slowest in person.
3. **Expand the coda to 2–3 slides** with the rich-get-richer example and the explicit callback to LaLonde's \$1,559 TWFE-with-id-FE result. As written it gestures at the punchline instead of landing it.
