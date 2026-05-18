# Synthesis — Compositional Change Audit (L6 + L7 of covariates.tex)
**Date:** 2026-05-12
**Auditors:** 3 independent agents, parallel
**Files audited:** `covariates.tex` (L6 lines ~893–1086, L7 lines ~1088–end)

## What the three agents converged on

The audit is not kind. All three agents independently flagged that the L7 section, while substantively close, has **factual errors, weak rhetoric, and a missing audience hook**. L6 (Caetano-Callaway) is more solid but has its own labels-not-assertions issues.

---

## 🚨 Substance errors (Agent 1) — these are objectively wrong

| # | Severity | Slide / Line | Error | Fix |
|---|---|---|---|---|
| 1 | High | L7-F2 / line 1124 | Hong cited as **JEEA**. Wrong. | Change to **JAE** (*Journal of Applied Econometrics* 28(2): 297–324) |
| 2 | High | L7-F4a / lines 1183–1185 | SX estimand is **inverted** — deck says target is "averaged over a fixed reference X-distribution, typically the **pre-period**." Actual SX target: $\tau = E[\tau(X) \mid D=1, T=1]$ — the **post-period treated** distribution. | Rewrite the estimand description to match the paper |
| 3 | Medium | L7-F2 / line 1117 | "Repeated cross-sections, **1996 and 2002**." Wrong. Hong's CEX window ends June 2001. | Change to **1996 and 2001** (or "1996–2001") |
| 4 | Medium | L7-F2c caption | Misdescribes the figures (`Hong_1.pdf` is internet diffusion + group expenditure; `Hong_2.pdf` is 4-region stacked plot of Internet × music-expenditure). Not "household-expenditure distribution." | Rewrite caption to match actual figures |
| 5 | Medium | L7-F4b | Hausman test framed as "naive DiD vs reweighted DiD." Actually: compares two DR estimators ($\hat\tau_{dr}$ vs $\hat\tau_{sz}$). | Rewrite test framing |
| 6 | Low / missed opportunity | L7-F2 | Hong's headline numbers absent (naive DD = −\$4.69; corrected = −\$1.45; 20% of total decline). | Add a numbers slide |
| 7 | Soft | L6-F0 | "Two channels" framing is the deck's, not CC's own framing. Not wrong, but flagged as a stylistic interpretation. | Optional — keep if pedagogically useful |

L6 (Caetano-Callaway) substantively passes — AIPW with $(X_{t-1}, Z)$ matches the paper.

---

## ⚠️ Rhetoric issues (Agent 2)

- **L7 titles: 1 assertion / 9 labels.** The SX section's "first, fix an estimand / second, test / third, reweight" reads as a textbook ToC. Almost no claims.
- **L7 fails application-first.** F1 opens with an abstract "two flavors" taxonomy table. Hong's story doesn't arrive until F2.
- **SX is a visual desert.** F4a, F4b, F4c are three consecutive text-only slides. Longest text-only stretch in the deck is **5 slides** (L7-F3 through F5).
- **L6 has zero figures across 8 frames.** Caetano-Callaway hidden-linearity-bias proof would benefit from a single picture.
- **Slammed slides:** L6-F2, L6-F5, L7-F1.

---

## ❌ Dev-economics framing (Agent 3) — FAILS the test

- **L7-F1 is a method-taxonomy slide, not a motivation slide.** Dev economists in the room don't see "this is for me" until at best L7-F5, four slides too late.
- **No LSMS, DHS, MICS, IFLS, IHDS** — the surveys dev economists actually run.
- **No "panels are expensive" assertion.** The economic rationale for repeated cross-sections is never stated.
- **Sant'Anna-Xu's own dev-econ application invisible.** Their empirical case is the South Africa–Mozambique trade corridor under SADC tariff reductions. The paper is in our readings. The slide block does not mention it. **Single highest-leverage missed asset.**

Agent 3 provided **full LaTeX for a proposed new L7-F0 slide** ("Most applied work doesn't have a panel") that names CPS/NLSY/ACS/CEX + LSMS/DHS/MICS/IFLS/IHDS, asserts panels are expensive, and pre-loads Hong (CEX) and Sant'Anna-Xu (SADC) as twin canonical examples. See `audit_3_devecon.md` for the full slide.

---

## Prioritized fix list (top 5)

1. **Add L7-F0 (dev-econ motivation slide)** — Agent 3's drop-in LaTeX. Highest leverage. Earns dev-econ attention up front.
2. **Fix the Hong factual errors** — JAE not JEEA (line 1124); 1996–2001 not 2002 (line 1117); figure captions (L7-F2c).
3. **Fix the SX estimand description** — the deck currently asserts the opposite of what the paper proves. This is the most embarrassing single error.
4. **Add a Sant'Anna-Xu empirical-example slide** — SADC trade corridor. Reuses an asset already in our readings. Lands dev-econ a second time, and gives SX a story rather than three pure-text estimand/test/correction slides.
5. **Convert L7 titles from labels to assertions** — particularly the SX block (F4a/F4b/F4c). Pair with a single SX visual (Hausman cartoon, or distribution-shift diagram) to break the 5-slide text wall.

## Out of scope (flagged for later)

- L6's zero-figures problem. CC's hidden-linearity-bias proof would benefit from a picture, but this is a Lesson 6 issue, not the urgent L7 set.
- The "two channels" framing on the L6 intro is a stylistic choice; Agent 1 flagged it but didn't call it wrong.

---

## Status

- All four audit artifacts written. File integrity ✓ (audit files all over the 500-word limit; that's fine, more detail is better).
- Hong PDF extracted; mapping to deck figures verified.
- No deck file modified yet — awaiting Scott's approval to apply the fix list above.
