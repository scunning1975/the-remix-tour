# Audit 1 — Assumptions 5 & 6 in Potential Outcomes (L2-F2f through L2-F2o)

## Math: PASS

Verified the algebra step by step against the structural model at F2g
(`Y^0_{it} = α_1 + α_2 T_t + α_3 D_i + β X_{it} + ε^0_{it}`):

- **F2h** treated/post (T=1, D=1): `α_1 + α_2 + α_3 + β·E[X|D=1,post]` — correct.
- **F2i** treated/pre (T=0, D=1): `α_1 + α_3 + β·E[X|D=1,pre]` — correct; α_2 drops as the gray phantom shows.
- **F2j** subtract: α_1 and α_3 cancel (correctly grayed); result `α_2 + β·ΔX^T` — correct.
- **F2k** control analog: post is `α_1 + α_2 + β·E[X|D=0,post]`, pre is `α_1 + β·E[X|D=0,pre]`; subtract → `α_2 + β·ΔX^C`. Correct.
- **F2l** set equal, α_2 cancels, `β(ΔX^T − ΔX^C) = 0`. Correct.
- **F2m** two cases stated correctly; the "Y^0's trend cannot depend on X" closer follows.
- **F2n** Assumptions 5 & 6 named; the parenthetical that the realized-X version is a *consequence* is exactly right.

No arithmetic, sign, or conditioning errors. The derivation is in PO throughout — the realized Y never re-enters.

## Pedagogy: PASS (with one tightening)

Working well:
- Titles are assertions ("subtract: the treated Y^0 trend", "two ways for β(ΔX^T−ΔX^C)=0 to hold", "Assumptions 5 & 6: Y^0 trends don't depend on X"). They carry the argument.
- One substitution per slide (F2h/F2i/F2j is the model move). Tempo feels like teaching, not a paper.
- Gray-for-cancellation and `\underbrace` for ΔX^T labels are doing real work — the eye sees the cancellation before reading the prose.
- F2f as a "what we need" preview is well placed; the warmgray italic question primes the next five slides.
- F2n's enumerated examples (rich/poor, men/women, college/dropout, old/young) translate the algebra into the lived constraint. This is the load-bearing pedagogical moment.

One issue: **F2g lists α_1, α_2, α_3, β as a four-item bullet right after the boxed equation.** This is the only slide in the 5–13 stretch that reverts to a labeling list rather than a single move. Consider replacing the bullets with inline `\underbrace` labels under each term in the equation itself — same information, half the cognitive cost, and consistent with the rest of the sequence.

## Connection to Post×X + unit FE: PARTIAL

F2o (the coda) flags that **β_pre ≠ β_post** is a separate failure mode and that Post×X is "designed to handle" it. That single slide is the only place the alternative spec appears in the proof block.

Three problems:
1. **No link back to the LaLonde lab numbers.** Scott's $3,522 (additive X) vs $1,559 (Post×X with unit FE) is the empirical payoff. The deck never says "this is why the two specs disagreed."
2. **Unit FE is not mentioned.** F2o introduces β_pre ≠ β_post but does not say that *adding unit FE* on top of Post×X is what absorbs time-invariant X levels and lets the interaction identify the trend shift. Without this, students will not see why the Day-2 lab spec uses *both*.
3. **The mapping is left implicit.** The crisp version Scott articulated — "additive X = β constant in time; Post×X = β_pre ≠ β_post; unit FE = absorb time-invariant X levels" — is not on a slide. It should be.

## Recommendations (prioritized)

1. **Add one slide after F2o** (call it F2p) with a three-row table: spec / what it relaxes / what it assumes. Rows: (a) TWFE + additive X → assumes β constant over t, ΔX^T=ΔX^C carries the burden; (b) TWFE + Post×X → relaxes β_pre=β_post; (c) + unit FE → absorbs time-invariant X levels so the Post×X coefficient is the *change* in slope. End the row with the LaLonde numbers ($3,522 / $1,559) so the abstraction lands on the concrete result.
2. **Strengthen F2o's closing line.** "We'll come back to it" is too soft after a five-slide build. Replace with: "This is the spec your Day 2 lab actually ran. The gap between $3,522 and $1,559 is this assumption failing."
3. **Tighten F2g.** Replace the four-item bullet list with `\underbrace` labels under the equation terms, matching the rhythm of F2h–F2l.
4. **Optional:** F2m's "Then why are we controlling for X?" is sharp but slightly flip. Consider: "Then X is doing no identification work — you're paying a degree of freedom for nothing." Same point, more pedagogically generous.
