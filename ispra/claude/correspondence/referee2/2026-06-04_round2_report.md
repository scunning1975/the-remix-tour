# Referee 2 — Round 2 Report
**Manuscript:** "Prevention Without Proof"
**Date:** 2026-06-04
**Reviewer role:** Referee 2 (adversarial econometric audit — second reading)

---

## Overview

The author has taken the round-1 report seriously and revised in good faith. The single integrity-
critical error (M1, the Italy sample/prose contradiction) is fully corrected; the most dangerous
piece of overreach (M3/M8, treating low power as affirmative evidence and asserting "the effect IS
the recession") is now disarmed by explicit, well-written concessions; the inference caveat (M2) and
the event-study reconciliation (M4) are added. The new robustness numbers are real — I reproduced all
three independently — and the prose is now consistent with the code and data. The paper's underlying
limitation (4 treated countries, a confounded panel) is unchanged and unfixable; but that limitation
*is the paper's thesis*, now stated honestly rather than papered over. I recommend acceptance with
trivial minor edits.

I verified the factual claims directly against `data/clean/panel.csv` and `output/estimates.json`,
and reproduced the three new robustness specifications with my own script
(`code/replication/referee2_round2_robustness.R`).

---

## Major points — disposition

### M1 — Italy in the prose but not the sample. **(a) Adequately resolved.**

This was the factual error and it is now correct. The revised Data section (lines 170–181) states
plainly:

> "The balanced panel retains the twelve of these with a complete suicide and unemployment record
> over 1994--2010---Austria, Switzerland, Czechia, Germany, Estonia, Greece, Spain, Hungary,
> Luxembourg, the Netherlands, Portugal, Slovenia---while Belgium, Denmark, Poland, Slovakia, and
> Italy are dropped for gaps in the suicide series."

I verified this against the data. The 12 listed controls are exactly AT, CH, CZ, DE, EE, EL, ES, HU,
LU, NL, PT, SI — each with a complete 17-year `suicide_sdr` record. Italy has 15/17 years (missing
2004 and 2005, confirmed in `panel.csv`); Belgium 14, Denmark 16, Poland 15, Slovakia 15 — all
correctly listed as dropped. `estimates.json` confirms `n_countries=16`, `n_treated=4`,
`treated=[IE,NO,SE,UK]`. The Appendix A passage (lines 484–488) is now consistent with the main text.

The Italy "hook" survives only in its truthful form (lines 177–181): Italy is described as a
documented never-adopter that *would* have been the natural control "had the data let us judge
them." That is accurate and rhetorically intact. The false "will reappear below as a fact" claim is
gone. Resolved.

### M2 — Few-cluster inference asserted, not defended. **(a) Adequately resolved.**

The new paragraph (lines 189–196) concedes the problem squarely:

> "With four treated countries and twelve controls the panel has on the order of sixteen clusters,
> far too few for the cluster-robust and multiplier-bootstrap standard errors the estimators report
> by default to be believed; I report them because convention demands it, but I do not lean on them,
> and neither should the reader. The inferential weight is carried instead by randomization
> inference---the in-space placebo of Section~6..."

This is exactly the fix requested: the SEs are reported but explicitly disowned as the inferential
basis, and the weight is shifted to randomization inference. The author does not over-correct into
claiming the placebo *establishes* a null (see M3). This is the honest position and it is now stated.
I would have welcomed a wild-cluster-bootstrap or MacKinnon–Webb p-value as a belt-and-suspenders
addition, but given that the paper's conclusion is uncertainty and it no longer leans on any SE-based
"significance," the omission is not disqualifying. Resolved.

### M3 / M8 — Low power as evidence for the null; "is the recession" overclaim. **(a) Adequately resolved.**

This was the deepest concern and the revision handles it cleanly. The calendar-time passage now reads
(lines 360–364):

> "I do not claim to know which, and the claim is not that the recession explains the result---to
> assert that would be to identify, from the same panel I have just called uninformative, an effect
> I have no business identifying. The claim is the weaker and more durable one: that these two forces
> are present, that the design cannot separate them from the policy, and that a number which confounds
> all three is not a measurement of any one."

That is precisely the recast M8 demanded — the recession is downgraded from a causal counter-claim to
"present but inseparable." The "independent diagnostics" overstatement (M3) is also fixed: the
Introduction (lines 103–107) now states "These diagnostics are not independent of one another...
but they are different windows onto the same wall," and the closing of Section 6 echoes it ("Five
windows, one answer. They are not independent of one another, but they fail together," lines 425–427).

The author did not add a formal minimum-detectable-effect calculation, which I had suggested as a way
to quantify "uninformative." I will not hold the paper hostage to it: the placebo p=0.25, the
Rambachan–Roth set spanning zero, and the now-explicit cluster caveat collectively communicate "the
design cannot detect an effect of plausible size" without a numeric MDE. The residual "indistinguishable
from chance" header (line 390) is the one spot where the old rhetoric peeks through, but the body
text under it correctly says only that the observed estimate is "an ordinary draw" — a "cannot reject"
statement, not an "is zero" statement. Acceptable. Resolved.

### M4 — Deep pre-period leads identified off 1–2 countries. **(a) Adequately resolved.**

The new two-caution paragraph (lines 335–342) is exactly what was asked for:

> "The deepest pre-adoption leads are identified almost entirely off the United Kingdom and Ireland,
> the only treated countries with long pre-histories; Norway and Sweden, adopting in 1995 with a
> single pre-period each, contribute to the *level* of the estimated effect but almost nothing to the
> *test* of trends, so the group-weighted estimand leans hardest on exactly the cohort that cannot be
> checked. And with four treated countries the joint pre-trend statistic is powered to catch only
> gross violations."

This correctly reconciles the e=−8…−2 leads in `estimates.json` (which are mechanically impossible
for the 1995 cohort, panel starting 1994) with the prose, and scales the claim back from "the treated
countries were diverging" to "a country or two visibly drifting." The headline ∑z²=59.4 (verified in
`estimates.json`) is reframed as "not a delicate finding... a design too small to see anything
subtle." Honest and correct. A per-cohort event-study figure would be a nice-to-have but is not
necessary now that the text no longer overclaims. Resolved.

---

## Minor points — disposition

- **Denmark-1998 robustness (was impossible).** Fixed. Lines 491–492 now state explicitly that
  Denmark "cannot be recoded as a 1998 adopter... because its suicide series is incomplete and it
  does not appear in the balanced panel." Correct — Denmark has 16/17 years and is dropped. The false
  round-1 claim is removed.

- **Sweden-2008, anticipation, post-communist (were asserted, now shown).** Fixed and **verified
  independently.** I reran all three from `panel.csv` with the `did` regression-adjusted CS estimator
  (`code/replication/referee2_round2_robustness.R`):

  | Spec | Paper | Referee replication |
  |---|---|---|
  | Drop post-communist (CZ,EE,HU,SI) | +1.24 (se 0.76) | **+1.241 (se 0.714)** |
  | Sweden recoded 2008 | +2.41 | **+2.405** |
  | One-year anticipation | +1.68 | **+1.681** |

  Point estimates match to the reported precision. (My SE on the post-communist spec is 0.71 vs the
  paper's 0.76; this is bootstrap-seed variation and immaterial.) The numbers are real and the
  qualitative claim — "the sign survives; the magnitude wanders with the specification" (line 421) —
  is supported. **One housekeeping note for the editor, not a barrier to acceptance:** these three
  specifications are not present in the committed `code/R/analysis.R`; they appear to have been run
  out-of-band. The author should fold them into the archived script so the replication package
  regenerates every number in the paper. (The leave-one-out, placebo, BJS, SA, +GDP-returns-NA, and
  primary CS results *are* all in `analysis.R` and consistent with `estimates.json`.)

- **+GDP returns NA.** Fixed. Lines 492–495 now state plainly that adding GDP "cannot be estimated
  at all, because the GDP-complete subsample is too small to support it---a limitation worth stating
  plainly rather than burying." Matches `estimates.json: cs_gdp_att="NA"`. The silent failure is now
  an acknowledged limitation. Good.

- **Post-communist control heterogeneity (round-1 M5).** Now addressed both as a robustness (above)
  and in the new line 416–419 ("A genuine treatment effect should not depend on which untreated
  countries one happens to compare against. This one does."). Adequate.

- **UK = England coding (m2).** Retained in Appendix A (line 482) and now also flagged in the main
  Data narrative implicitly via the leads caution (M4). Acceptable; a one-line mention in the body
  would still be marginally better but is not required.

- **m9 prose / advocacy register.** The author respectfully retains the Weitzman voice and I accept
  the argument: for a paper whose entire content is the morality of governing without evidence, the
  register is defensible. The worst offenders flagged in round 1 are pruned; "the recession wearing
  the policy's clothes" (line 359) now sits inside an explicitly hedged "may be... it may be
  selection; it may be noise" sentence, which defuses it.

---

## Remaining quibbles (do not block acceptance)

1. The section header "It is indistinguishable from chance" (line 390) still phrases a "cannot
   reject" result as an "is chance" result; the body text is correct, so this is a header-vs-body
   tension. Consider "It is indistinguishable from a placebo" or "It does not stand out from chance."
2. Fold the three new robustness specs into `analysis.R` so the archive is self-regenerating (see
   above).
3. `FINDINGS.md` working-title reconciliation (round-1 m1) — internal, cosmetic.

These are copy-edits, not revisions. None bears on a conclusion.

---

## Assessment

The paper's design is inherently limited — four treated countries, a panel that begins after the
first cohort's only pre-period, post-periods that fall on the 2008 recession. That limitation cannot
be engineered away, and the round-1 report did not ask the author to manufacture treated countries
that do not exist. What the report asked for was that the *non-result be airtight and honest*: no
factual contradiction with the sample, no inference asserted beyond what 16 clusters can bear, no low-
power "cannot reject" smuggled in as "is zero," and no unidentified recession counter-claim. On every
one of those four major axes the revision delivers. The remaining limitation is now the paper's
openly-stated subject, not a concealed flaw. The central methodological lesson — that a single pre-
Goodman-Bacon TWFE estimate cannot license the diffusion of a life-and-death policy — is correct,
important, and now cleanly defended. The cross-language replication remains a genuine strength and I
detected no fabrication; the three new numbers reproduce to the decimal.

This is publishable. I would accept it, conditional only on the trivial copy-edits above, which need
no further referee round.

---

RECOMMENDATION: Minor revision
