# Response to Referee 2 (Round 1)

I thank the referee for an exacting and fair report. Every major point identified a real problem;
I have made every change I agree with, which is nearly all of them. Below, point by point.

## Major points

**M1 — Italy is not in the estimation sample (factual error).** Correct, and the most important
catch. Italy's suicide series is missing 2004--2005, so it is excluded from the balanced panel. The
prose claimed Italy "will reappear below as a fact." It does not. I have rewritten the data section
to state plainly that Italy is dropped from the balanced estimand for missing data, to list the
actual twelve controls (AT, CH, CZ, DE, EE, EL, ES, HU, LU, NL, PT, SI) and the five dropped
countries (BE, DK, IT, PL, SK), and to reframe Italy honestly as the documented never-adopter that
*would* have been the natural control had the data permitted. The rhetorical hook survives only in
its truthful form.

**M2 — Few-cluster inference asserted, not defended.** Agreed. I added a paragraph in Section 4
stating that with ~16 clusters the default cluster-robust/bootstrap SEs cannot be trusted, that I
report but do not lean on them, and that the inferential weight is carried by randomization
inference (the in-space placebo, $p=0.25$). Significance language elsewhere is softened accordingly.

**M3/M8 — Low power used as affirmative evidence; "is the recession" overclaims.** Agreed and
important. I rewrote the calendar-time passage to stop asserting that the recession explains the
result---which would identify, from a panel I have called uninformative, an effect I have no
business identifying---and to make the weaker, durable claim: selection and the recession are
present, the design cannot separate them from the policy, and a number confounding all three
measures none. I also rewrote the "four/five independent diagnostics" lines to concede openly that
the diagnostics are *not* independent (the sensitivity analysis formalizes the pre-trend; placebo
and SCM are both small-treated-group statements), recasting them as different windows onto the same
wall.

**M4 — Deep pre-period leads identified off 1--2 countries.** Agreed. Added a two-caution paragraph
to the event-study section: the long leads are identified essentially off the UK and Ireland;
Norway and Sweden (one pre-period each) feed the level of the ATT but not the trend test, so the
group-weighted estimand leans on the cohort that cannot be checked; and the joint pre-trend test is
powered only for gross violations.

## Minor points (addressed)

- **Denmark-1998 robustness was impossible** (DK is dropped): removed the false claim; stated
  explicitly that it cannot be tested.
- **Sweden-2008 and anticipation**: now *shown* with real numbers ($+2.41$; $+1.68$), not asserted.
- **+GDP specification returned NA**: now stated plainly that it cannot be estimated because the
  GDP-complete subsample is too small---reported as a limitation, not hidden.
- **Post-communist controls**: added as a robustness; dropping CZ/EE/HU/SI nearly halves the
  estimate to $+1.24$ (s.e.\ $0.76$), which I now use as *further evidence of fragility*, not
  against the thesis.
- **UK = England coding**: already flagged in Appendix A; retained.
- **Anticipation**: now reported.

## Points respectfully retained

The Weitzman-register prose is deliberate and, I argue, appropriate to a result whose entire
content is moral: that we cannot tell whether a life-and-death policy saves lives. I have pruned the
places where rhetoric outran evidence (above), but kept the voice.

The revised manuscript is resubmitted for a second reading.
