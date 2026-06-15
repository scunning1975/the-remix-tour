# Referee 2 — Round 1 Report
**Manuscript:** "Prevention Without Proof"
**Date:** 2026-06-04
**Reviewer role:** Referee 2 (adversarial econometric audit)

---

## (a) Summary of contribution

The paper re-examines whether national suicide-prevention strategies reduced suicide, using a
staggered-adoption design on a European country-year panel (1994–2010) and the modern
heterogeneity-robust toolkit (Callaway–Sant'Anna primary; Borusyak–Jaravel–Spiess and Sun–Abraham
as cross-checks; Rambachan–Roth sensitivity; in-space placebo; augmented synthetic control). Its
honest and unusual thesis is that the naive estimate is *positive* (~+2.7 suicides/100k), that this
positive estimate is non-causal (pre-trends fail, the effect loads on the 2008 recession, the
propensity score perfectly separates, Rambachan–Roth cannot sign it, placebo p-values are large),
and that the cross-national observational record therefore *cannot identify* the policy's effect.
The cross-language replication (R/Python/Stata) and the layered falsification are genuine strengths.

## (b) Assessment

This is a brave, well-executed, and refreshingly honest paper, and I want to be clear at the outset
that the **central methodological lesson is sound**: a 2002/2005 staggered design whose post-periods
fall on the 2008 recession, with violated pre-trends, cannot deliver a credible ATT, and the field's
reliance on a single pre-Goodman-Bacon TWFE estimate is fairly criticized. The replication is clean
and I detected no fabrication.

But a paper whose entire argumentative move is "here is a positive estimate, and here is why you
should not believe it" carries a special burden: the *non-result* must itself be airtight, because
the reader's natural suspicion is that the author is explaining away an inconvenient sign. On that
standard the manuscript is not yet there. There is a factual inconsistency between the prose and the
estimation sample (Italy), the inference with ~16 clusters is asserted rather than defended, the
"four/five independent diagnostics" are far less independent than claimed, and a central
event-study object (the deep pre-period leads) is mechanically impossible for half the treated
group and is never reconciled. These are fixable, but they are major.

---

## (c) MAJOR points (must be fixed)

**M1. The estimation sample contradicts the prose — Italy is NOT in it.**
Sec. Data (lines 169–172) lists Italy among the never-treated controls and stakes a rhetorical
flourish on it: *"Italy, the country in which these words are being read, is among the
never-adopters, and will reappear below not as a footnote but as a fact."* Appendix A (line 443)
repeats the claim. **This is false.** The balanced-panel filter in `analysis.R` (lines 36–38)
keeps only countries with a complete suicide series, and Italy is missing suicide data for 2004–2005
(verified in `data/clean/panel.csv`). The actual 12 retained controls are AT, CH, CZ, DE, EE, EL,
ES, HU, LU, NL, PT, SI — Italy, Belgium, Denmark, Poland, and Slovakia are all dropped. The paper
names a 14-country control list (lines 169–171, 443) and says "the balanced panel retains the
twelve with a complete record," but never tells the reader *which* twelve, and the one country it
names explicitly is not among them. For a paper prepared *for the JRC at Ispra* whose narrative hook
is Italy, this is not a cosmetic error. Fix: state the exact 12 controls; either restore Italy via
`allow_unbalanced_panel=TRUE` (it has 15/17 years) and show robustness, or drop the Italy framing
entirely. Do not leave the prose asserting a fact the code contradicts.

**M2. Inference with ~16 clusters is asserted as credible but never defended.**
The design has 4 treated and 12 control clusters. The SEs come from the `did` multiplier bootstrap
(`bstrap=TRUE, biters=2000`), which is justified asymptotically in the *number of clusters* — a
regime this paper is nowhere near. With 16 clusters and only 4 treated, standard cluster-robust /
multiplier-bootstrap inference is known to over-reject severely (Cameron–Gelbach–Miller;
MacKinnon–Webb on few treated clusters). The reported SEs (1.05, 1.24, 1.30, 1.38) and the implied
"~2σ" pre-trend rejections should be treated with great suspicion. The paper's saving grace is that
its *conclusion* is uncertainty, so understated precision only helps it — but the pre-trend
rejection (∑z² = 59.4) and the placebo are inference objects too, and the author cannot have it both
ways: if the SEs are untrustworthy when they would support an effect, they are untrustworthy when
they reject parallel trends. Required: (i) report wild-cluster-bootstrap or MacKinnon–Webb-style
few-treated-cluster inference, or at minimum a randomization-inference p-value for the pre-trend
test; (ii) state explicitly that conventional clustered SEs are not reliable at this cluster count
and that the *qualitative* (not numerical) reading is what survives.

**M3. The "four/five independent diagnostics, four/five verdicts" claim overstates independence.**
The Introduction (lines 103–104) and Sec. "What the Number Is Not" (line 384) sell five
*independent* diagnostics converging on "undetermined." They are not independent. (a) The
Rambachan–Roth result that the effect "cannot be signed" is *mechanically driven by the same
pre-trends* the event study reports — it is a restatement, not corroboration. (b) The placebo
p = 0.25 and the SCM p = 0.46/0.69 are both null-power statements about the same tiny treated group;
they say "we cannot reject the null," which for 4 (or 2) treated units against a noisy outcome is the
*expected* outcome regardless of truth, not evidence the estimate is "indistinguishable from chance"
(line 360). The paper repeatedly slides from "cannot reject" to "is chance" / "is the residue of
timing" (e.g., lines 92–93, 332, 363, 384). That is the precise overreach a skeptic will pounce on:
**low power cannot be used as affirmative evidence for the null.** Recast as: the design has neither
the identification (pre-trends) nor the power (cluster/treated count) to detect an effect of
plausible size — and quantify that plausible size with a minimum-detectable-effect calculation. The
honest claim is "uninformative," and the paper sometimes says that, but the rhetoric repeatedly
upgrades it to "the effect is the recession," which is itself an unidentified causal claim.

**M4. The deep pre-period event-study leads are impossible for the 1995 cohort and never reconciled.**
The event study (`estimates.json`, Fig. 8) reports coefficients at e = −8,…,−2. But Norway and
Sweden adopt in 1995 with the panel starting in 1994 — they have *exactly one* pre-period (e = −1),
which the paper itself concedes for SCM (lines 376, 499–501). Therefore every event-time lead
deeper than e = −1 is identified *entirely off UK (2002) and Ireland (2005)*, and the deepest leads
(e = −8, −7) off the UK alone. The headline pre-trend statistic (∑z² = 59.4 over 8 leads) is thus
not "the treated countries were already diverging" (lines 86, 314) — it is "one or two countries
were diverging," with the deepest, most-weighted leads resting on a single country. The cohort
composition that drives the leads must be shown (a per-cohort event study, or at least which cohorts
contribute to each e), and the prose claiming a general pre-existing divergence ("the treated
countries," "an Ashenfelter ascent") must be scaled back to what 1–2 countries can support. This
matters doubly because the group ATT up-weights the 1995 cohort (2:1:1), the *one* cohort that
contributes almost nothing to the pre-trend diagnosis.

**M5. The never-treated control pool mixes incomparable suicide regimes.**
The retained controls include four post-communist states (CZ, EE, HU, SI) whose suicide dynamics
over 1994–2010 (sharp transition-era spikes then declines, especially EE and HU which begin near the
top of the European distribution) are driven by forces utterly unlike those in NO/SE/UK/IE. The
balance table (Table 2) shows treated suicide at 12.0 vs control 19.0 — a −0.88 standardized
difference — and a large part of that gap and its trend is the post-communist bloc. Conditional
parallel trends across such heterogeneous regimes on the strength of *one* covariate (unemployment)
is a strong assumption. The paper should (i) show robustness to excluding the post-communist
controls, and (ii) acknowledge that "never-treated" here pools Western European and transition
economies whose Y(0) trends have no reason to be parallel. This is also relevant to the placebo
(M3): random reassignment among such heterogeneous controls inflates placebo dispersion, mechanically
making the observed estimate look "ordinary."

**M6. Conditional parallel trends on a single covariate is under-defended.**
The paper is candid that it conditions only on unemployment (lines 191–200) and argues unemployment
is the dominant fast-moving confound — a reasonable prior. But the regression-adjustment CS estimator
conditions on *baseline/period* unemployment in a specific way, and the paper never shows that the
adjustment actually closes the pre-trend it diagnoses (it does not — the conditional event study
still fails). Two things are needed: (i) be explicit that conditioning on unemployment does *not*
restore parallel trends (the honest and interesting point — the pre-trends survive adjustment), and
(ii) defend the *omission* of contemporaneous GDP from the primary spec given that the recession is
the paper's central confounder. The +GDP robustness returns NA (`estimates.json: cs_gdp_att="NA"`,
`analysis.R` line 197 collapses the GDP subsample because of missing 1994 GDP for many countries) —
so the paper's claim that aging/income "are absorbed by the country and year structure" is asserted,
not shown, and the one specification that would test it failed silently. Report why it failed and
what, if anything, can be salvaged.

**M7. Robustness to alternative treatment codings is asserted, not shown.**
Appendix A (lines 445–447) states recoding Denmark as a 1998 adopter and using Sweden's 2008
parliamentary date "is reported in the replication archive and does not change the conclusions." But
(a) Denmark is *dropped from the estimation sample entirely* (missing 2010 suicide — verified), so it
cannot enter as a treated unit without changing the panel; the claim is not reproducible as written.
(b) The Sweden-2008 recode is consequential: it would move one of the two 1995-cohort units into the
recession window and is exactly the kind of measurement-error check the design needs — it must be
*shown* (a row in Table 1 or a panel in an appendix figure), not gestured at. Given that the entire
paper hinges on adoption-date timing relative to 2008, treatment-date measurement error is a
first-order threat, and "see the archive" is not acceptable for the load-bearing robustness.

**M8. The headline causal counter-claim ("the effect IS the recession + reverse causation") is itself unidentified.**
The paper's thesis is not merely "we cannot identify the protective effect" (defensible) but the
stronger, repeated claim that the positive estimate *is* the recession plus adoption-in-crisis
(lines 87–93, 314–315, 332, 397–399). That is a competing *causal* decomposition, and the data that
cannot identify the policy effect equally cannot identify this alternative. The calendar-time
aggregation (Fig. 8c) is suggestive but is the same group-time ATTs re-summed — it shows *when* the
ATT is large, not that the recession *causes* it net of the policy. To make the recession claim the
author would need a design that is not available here (e.g., the policy effect identified off the
pre-2008 cohorts, or an interaction with country-specific recession severity). Either downgrade the
recession claim to "consistent with" / "a leading candidate explanation," or provide identification
for it. As written it commits the same sin the paper accuses the field of: reading a causal story off
a confounded panel.

---

## (d) MINOR points

- **m1. Abstract vs. FINDINGS title mismatch.** The manuscript title is "Prevention Without Proof";
  `FINDINGS.md` line 58 still carries the working title "The Arithmetic of Despair." Reconcile.
  "Prevention Without Proof" is good — accurate, no colon, not overclaiming.
- **m2. UK = England-only coding.** Appendix A (line 439) notes the UK strategy is England's while
  Eurostat reports UK aggregate. This is a real measurement-error issue (Scotland 2002, Wales later,
  Northern Ireland 2006 had distinct timelines) and deserves a sentence in the main text, not just
  the appendix, since the UK contributes the deepest event-study leads (see M4).
- **m3. Anticipation.** No anticipation window is allowed (`base_period="varying"`, no leads-as-
  treatment). For a policy literally adopted in response to rising suicide, anticipation/announcement
  effects in the year or two before formal adoption are plausible and would further contaminate e=−1,
  the reference period. Address explicitly; consider a robustness with a 1-period anticipation window.
- **m4. Placebo design detail.** The in-space placebo (`analysis.R` lines 249–262) draws fake
  adoption years from {1998, 2002, 2005} — but the real 1995 cohort year is excluded from the draw,
  so the placebo distribution is not matched to the actual rollout. Minor, but state the draw set and
  why 1995 is omitted (presumably the single-pre-period problem), and note it makes the placebo a
  conservative-or-not comparison.
- **m5. Standardized-difference denominator / balance table baseline.** Balance (Table 2) uses each
  country's earliest observed year (`analysis.R` line 88), which differs across countries (e.g.,
  1994 for most). Fine, but say so; "baseline" is ambiguous when entry years differ.
- **m6. "Doubly robust... reported to show they change nothing" but SEs are dashes.** Table 1 reports
  DR/uncond/NYT point estimates with no SEs ("—"). Either report them or say why they are omitted;
  a referee cannot judge "changes nothing of substance" from a point estimate alone.
- **m7. ∑z² = 59.4 "against a distribution that should rarely exceed fifteen" (line 310).** Name the
  reference distribution (χ²₈ has 95th pct ≈ 15.5) and, per M2, give a randomization-inference
  version, since the χ² calibration assumes the very large-cluster asymptotics the design lacks.
- **m8. Reproducibility of figures.** `analysis.R` writes `placebo_p` to `estimates.json` (0.25) but
  the figure caption and text round consistently; good. The HonestDiD block has a fallback path
  (lines 155–172); confirm which path actually produced Fig. 9 and report M̄ values and the npre/npost
  used, since the leads count interacts with M4.
- **m9. Prose / journal fit.** The Weitzman-style moral framing is largely effective and the candor is
  the paper's signature, but several passages outrun the evidence and will draw editor fire: "We are
  governing mortality on faith" (abstract), "the recession wearing the policy's clothes" (line 332),
  "navigating in the dark and calling it sight" (line 108), "the light we thought we had was never
  there" (line 422). One or two such lines land; a dozen reads as advocacy. Trim by half. Also "more
  than war, more than homicide" (line 50) needs a citation. The repeated insistence that the finding
  is *not* nihilistic (lines 106–112, 387–422) protests slightly too much.
- **m10. "Three estimators agree to within a fraction of a death" (lines 84, 268–269).** True for the
  point estimates, but they are *not* independent evidence of robustness — BJS, SA, and CS all assume
  the same (violated) parallel trends and use the same data; their agreement says the estimators are
  implemented correctly, not that the number is credible. Reword to avoid implying corroboration.
- **m11. France drop.** Dropping France (no pre-period) is defensible and clearly justified (line 442).
  Finland likewise. No objection — but note France's exclusion removes the *2000* cohort, leaving a
  4-unit/3-cohort design; say a word about how much identifying variation is lost.

---

## (e) Recommendation

**Major revision.** The core lesson is correct and the honesty is valuable, but a factual prose/sample
contradiction (Italy), inference that is asserted rather than defended at ~16 clusters, an
event-study pre-trend that rests on 1–2 countries, and a recession counter-explanation that is itself
unidentified mean the non-result is not yet airtight enough to publish as written.

---

**One-line recommendation:** Major revision — the design critique is sound and the candor admirable,
but fix the Italy sample/prose contradiction, defend few-treated-cluster inference, stop using low
power as evidence for the null, and reconcile the deep pre-period leads that only 1–2 countries can
identify.
