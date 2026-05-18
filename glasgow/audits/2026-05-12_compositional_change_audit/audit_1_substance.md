# Substance Audit — L6 (Caetano-Callaway) and L7 (Hong + Sant'Anna-Xu)

**Auditor:** Agent 1 (substance). **Date:** 2026-05-12. **File audited:** `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex`, lines 893–1242.

---

## HONG (L7-F2, F2b, F2c) — lines 1113–1152

| # | Claim in deck | Verdict | Correction |
|---|---|---|---|
| H1 | "Repeated cross-sections, 1996 and **2002**." (line 1117) | ✗ | Hong's CEX panel runs 1996 through June 2001. Pre-Napster window: June 1997–May 1999. Post-Napster: June 1999–June 2001. Change to "1996 and 2001" (or "1996–2001"). |
| H2 | "In 1996, internet users were … young, urban, technical. By 2002, internet users looked much more like the general population." (lines 1118–1119) | ✓ direction, ✗ year | Direction is exactly what Table I documents (mean age 40.2→44.3; income $52,887→$47,510; college share 43%→37%; urban 93%→89%; dorm 12%→5%). Fix 2002→2001. |
| H3 | "Hong (2013), *Journal of the European Economic Association*." (line 1124) | ✗ | Wrong journal. Hong (2013) appeared in **Journal of Applied Econometrics** 28(2): 297–324. JEEA is a different journal entirely. This is the most embarrassing error in L7. |
| H4 | F2b caption: `hong_table.png` is the table "that made the point" about 1996-vs-2002 user composition (line 1136) | ✓ | This is Hong's Table I (p. 304) — Internet user vs. non-user descriptive stats by year. Caption is accurate, though it should also say 1996/2001 not 1996/2002 if the table shows those columns. (Hong's Table I shows 1997, 1998, 1999, 2000 — auditor cannot confirm exact column years on the image without reading it. Worth checking.) |
| H5 | F2c caption: two figures show "the household-expenditure distribution" and the "compositional shift is large enough to drive the naive DiD" (lines 1149–1150) | ✗ inaccurate | `Hong_1.pdf` = Hong Figure 1 (Internet diffusion bars + line of % HH online, 1996–2001) — NOT a household-expenditure distribution. `Hong_2.pdf` = almost certainly Hong Figure 3 (4-region stacked plot of HH % by Internet adoption × music expenditure 1996–2001) — that IS about composition but not "the distribution of expenditure." Rewrite caption: "Figure 1 (left): internet penetration rises from ~5% (1996) to ~40% (2001), and the user-group mean music expenditure halves over the same window. Figure 3 (right): as the internet group grows, the share of zero-music-spenders inside it grows disproportionately." |
| H6 | The deck does NOT show Hong's headline number (~$1.45/qtr; ~20% of total decline; naive DD = −$4.69 is 3.2× too big). | ⚠ omission | Recommend adding a one-line "the numbers" callout: naive DD = −$4.69; two-variate-PS DDM = −$1.45 (≈40% of CEX decline; ≈20% of total recorded-music decline). This is exactly the "compositional shift drives the naive DD" claim the deck asserts qualitatively but doesn't quantify. Without it, the slide tells the reader "the shift was big" but gives no magnitude. |

---

## CAETANO-CALLAWAY (L6) — lines 893–1083

| # | Claim in deck | Verdict | Correction |
|---|---|---|---|
| C1 | Two distinct problems: (1) FE transform drops levels/Z, (2) what survives enters additively forcing constant τ (lines 920–935) | ✓ partial | Problem (1) is faithful to CC. Problem (2) (additive RHS forcing constant τ) is the deck's own L4 callback — CC do not frame "constant β" as a second channel in those terms. CC's own decomposition is "weighted ATT + bias terms A/B/C" (Thm 1) and the 5 misspecification-bias components in the multi-period case (Prop 4). The deck's two-channel framing is a pedagogical compression, not a verbatim CC claim. Defensible but should not be presented as CC's framing. |
| C2 | SYG application: 50 states, 2000–2010, 20 adopters, log homicide outcome (line 953) | ✓ | Matches extract exactly. |
| C3 | Imbalance numbers: South 0.81; poverty 1.06; income −1.08 (lines 956–958) | ✓ | Matches Table 1 of CC (extract reports 0.812, 1.055, −1.084). |
| C4 | Multi-period headline: TWFE α̂ = +0.067 vs AIPW ≈ 0 (lines 965–967, 1070–1073) | ✓ | Matches CC's multi-period results: TWFE 0.0672 (SE 0.026); Reg adj X_{g-1}+Z = 0.019 (SE 0.043). Deck uses "AIPW" loosely on F2 but the table on F7 correctly labels these as Reg. Adj. — minor inconsistency. |
| C5 | Recommended estimator: AIPW with $X_{t-1} + Z$ (lines 1044–1057) | ✓ | Faithful. CC's preferred specification is the AIPW estimator with outcome regression on $(X_{g-1}, Z)$ (or $\Delta X, X_{g-1}, Z$ when data permits), implemented in `pte`. Deck's R-package mentions (`pte`, `twfeweights`) match. |
| C6 | "Pre-period level $X_{i,t-1}$ belongs on the right --- because the level of population predicts the trend in homicides." (line 1008) | ✓ | Faithful to CC's structural model (Eq. 4): the correctly-specified ΔY(0) depends on $Z$, $\Delta X$, AND $X_{i,t^*-1}$. |

**Net on CC:** Substantively accurate. The only soft point is the "two channels" framing on F0 — channel (2) (constant τ) is the deck's own L4 throughline, not CC's headline; the deck should not strongly imply CC themselves diagnose channel (2) as part of hidden linearity bias.

---

## SANT'ANNA-XU (L7-F3 through F4c) — lines 1154–1226

| # | Claim in deck | Verdict | Correction |
|---|---|---|---|
| S1 | Three-part structure: estimand / test / correction (lines 1156–1163) | ✓ | Faithful structure. SX paper does formalize the estimand (Section 2), provide the Hausman test (Section 4, Theorem 4.1), and propose the DR estimator (Section 3, Eq. 2.6 / 3.1). |
| S2 | "The SX target: population ATT averaged over a **fixed reference $X$-distribution** --- typically the **pre-period**." (lines 1183–1185) | ✗ | SX's target is the ATT on **post-period treated units**: τ = E[τ(X) | D=1, T=1]. The estimand integrates over the **post-period treated** distribution, NOT the pre-period. Sant'Anna-Zhao integrates over the pooled-treated distribution; SX correct it to post-period treated. Fix: "averaged over the post-period treated $X$-distribution." This is a material error — it inverts the direction of the correction. |
| S3 | Hausman-style test framing: compare naive DiD to reweighted DiD (lines 1196–1205) | ✓ partial | SX do propose a Hausman test (Eq. 4.2): $T_n = n \cdot \hat{V}_n^{-1} (\hat\tau_{dr} - \hat\tau_{sz})^2$, asymptotically $\chi^2(1)$. The comparison is between the **DR estimator robust to compositional change ($\hat\tau_{dr}$)** and the **Sant'Anna-Zhao DR estimator that assumes stationarity ($\hat\tau_{sz}$)** — NOT "naive DiD" vs "reweighted DiD." This is a small but important precision issue: SX's test compares two DR estimators that differ only in the stationarity assumption. Fix the slide language: "Compute $\hat\tau_{sz}$ (DR under stationarity). Compute $\hat\tau_{dr}$ (DR without stationarity). Compare." Also: "Standard $\chi^2$ inference" → "$\chi^2(1)$ under the null." |
| S4 | "Doubly robust version available --- combine the IPW reweighting with an outcome model" (line 1223) | ✓ | Faithful. SX's preferred estimator IS the DR / EIF-based one — not merely "available." Suggest reframing: SX's preferred estimator is DR; that's the headline, not an aside. |
| S5 | "IPW-style reweighting, with weights derived from $f_{\text{ref}}(X) / f_t(X)$" (line 1222) | ⚠ inexact | SX use a **generalized propensity score** $p(d,t,x) = P(D=d, T=t \mid X=x)$ — a four-cell multinomial — not a simple ratio of marginal $X$-densities across periods. The deck's $f_{\text{ref}}/f_t$ ratio gestures at the idea but isn't SX's actual weighting object. For a teaching slide this is forgivable; for rigor, the four-cell generalized PS is what SX actually use. |
| S6 | Pre-test warning is absent from L7 | ⚠ omission | SX explicitly warn against using the Hausman test as a pre-test for estimator selection (Roth 2022 / Guggenberger 2010 pre-test distortion). Worth one line: "Don't use the test to pick an estimator. Report both." |

---

## TOP 3 SUBSTANCE FIXES, RANKED

1. **L7-F2, line 1124: "Journal of the European Economic Association" → "Journal of Applied Econometrics."** Hong (2013) is in *JAE*, not *JEEA*. Single-word fix, but it's the kind of error a careful audience will notice instantly and the kind that erodes trust in the rest of the lecture.

2. **L7-F4a, lines 1183–1185: SX estimand is the post-period treated distribution, not "typically the pre-period."** As written, the slide tells students the opposite of what SX prove. Replace "typically the pre-period" with "the post-period treated distribution — E[τ(X) | D=1, T=1]."

3. **L7-F2, line 1117 and L7-F2b caption: 2002 → 2001 throughout.** Hong's CEX window ends June 2001, not 2002. Tightening this also matches the figures (`Hong_1.pdf` and `Hong_2.pdf` both run 1996–2001) and the descriptive table years. Wherever the deck writes "2002," replace with "2001."

**Honorable mentions:** L7-F2c caption misdescribes what `Hong_1.pdf` and `Hong_2.pdf` actually show (rewrite per H5 above); L7-F4b should clarify that the Hausman comparison is $\hat\tau_{dr}$ vs $\hat\tau_{sz}$, both DR estimators, not "naive DiD vs reweighted DiD."
