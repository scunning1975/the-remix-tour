# Audit 3 — Post×X + id-FE connection

## Is the link drawn clearly in the current deck?

**No.** The link is gestured at but not built. After thirteen carefully-sequenced proof slides culminating in the named Assumptions 5 & 6 (L2-F2n), the coda L2-F2o introduces β_pre ≠ β_post in a single half-slide, names "Post × X interactions" once in *warmgray italic*, and ends with "We'll come back to it." The deck never comes back. The lab-intro slide (L2-Lab, line 1223) tosses off "TWFE-with-X (interact Post × X --- without the interaction, FE sweeps them out)" in a sub-bullet of a sub-bullet, with zero pedagogical scaffolding. And `lalonde.tex` line 585 publishes `reg re ever_treated##post X, robust` as "DiD with additive X" with no contrast spec shown — the \$3,522 vs. \$1,559 distinction Scott just discovered is invisible to the student.

The CI-2 original (`02-Covariates.tex`) does **not** make this distinction either — it stays inside additive-X TWFE and never raises Post × X with id FE. So there is no inherited scaffolding to lean on; this needs to be built fresh.

## Is the coda enough?

No. The coda raises a real question — *what if β varies over t* — and then drops it. Worse, it does so right after the climax slide where Assumptions 5 & 6 are named. The current sequence is: build, name, then immediately undercut with "by the way, here's another failure mode." The student leaves uncertain which assumption matters.

## Proposed expansion (4 slides after L2-F2o)

These should sit *after* L2-F2o, before the OR section. They convert the coda into the actual punchline Scott suspects it is.

1. **L2-F2p — "Two specs, two different assumptions"**  
   Side-by-side: Spec A is `reg Y i.D##i.Post X` (one β, no FE); Spec B is `reghdfe Y D##Post Post#c.X, abs(id)` (id FE sweeps level of X, Post×X lets β shift). One sentence: *these are not the same regression in disguise.*

2. **L2-F2q — "What Spec A assumes (and what it buys)"**  
   Spec A imposes Assumptions 5 & 6: Y⁰'s trend cannot depend on X, with a single time-invariant β. The realized-X cost: \$3,522 on LaLonde. This is what makes additive-X identify ATT.

3. **L2-F2r — "What Spec B assumes (and what it buys)"**  
   Spec B drops "β constant over t" but adds a new restriction: within-person changes in X must have the same effect for treated and control (no D × Post × X). id FE absorb every time-invariant trait — sex, race, schooling — so those Xs literally cannot enter. The realized-X cost: \$1,559 on LaLonde.

4. **L2-F2s — "Same data, two answers, two assumption sets"**  
   Pin the \$3,522 vs. \$1,559 gap. Neither is "right" — they identify under different DGPs. The DR-DiD estimators (next section) sidestep both by not putting X on the additive RHS at all.

## Verdict

**Clarifies, decisively.** The expansion does not bury Assumptions 5 & 6 — it gives them a foil. Right now Assumptions 5 & 6 hang in the air as "an assumption you might violate"; with the expansion they become "the price Spec A pays, and here is the alternative price." The LaLonde numbers (\$3,522 vs. \$1,559) turn the abstract math into a number gap students can see. Without the expansion the coda is dead weight; with it, the proof block has a real third act and the lab comparison table earns its place. Build the four slides.
