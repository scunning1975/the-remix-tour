=================================================================
                        REFEREE REPORT
       Glasgow Day 1–2 Decks (basics, triple-diff, covariates)
                        Round 1
                  Date: 2026-05-11
=================================================================

## Summary

Audited three compiled Beamer decks for a PhD mini-course at Glasgow, May 18–22, 2026: `basics.pdf` (114 frames), `triple-diff.pdf` (30), `covariates.pdf` (45). All three compile with **zero overfull/underfull warnings** and the rhetorical bones are sound: narrative-first openings, story-of-thought lessons, codeblocks beside estimators, a Popperian closing arc. They comply with Scott's stated rhythm more than they break it. Principal concerns: (1) two of three closing slides are visually broken by a TikZ rule striking through body text; (2) Day 1 opens with eleven meta-slides before the first DiD assertion, violating "lead with a problem"; (3) covariates Lesson 6 dilutes the L4→L6 through-line by introducing a *second* mechanism for TWFE-with-controls bias (FE transformation drops levels) on top of L4's mechanism (additive RHS forces constant τ), without flagging that they are two diseases, not one. Verdict: **Minor Revisions**.

---

## Audit per deck

### basics.pdf — Day 1 Foundations (114 frames)

**What works.** Lesson 1 (Three Inventors) is exactly Scott's voice — history of thought before formalism, three stories before the regression. Snow's table (slide 25) and the "two paths are two regressions" code slide (slide 26) are textbook Narrative→Picture→Codeblock. The eight-person / ten-person potential-outcomes tables (slides 41–47) are vivid concrete-before-abstract pedagogy. The Lesson 6 weighted-PT block (slides 93–99) is the strongest passage: identity → conditional application → knife-edge → simulation → "not a robustness check" — six slides, one assertion each, math accumulates. The "Five Parts of a Strong DiD" → "Falsification puts a rival theory on trial" → "Event study is the falsification built into the timeline" sequence (slides 102–105) is the rhetorical peak.

**What breaks the rhythm.** Slides 2–11 are not about DiD. They are about the week, Scott, Claude Code, APE, the assessment. **Eleven slides before the question** ("DiD is a research design, not a regression," slide 14). Substack_style.md: "Never open with an abstract claim. Open with a thing that happened." Slides 2, 3, 11 are obligatory throat-clearing. The APE slides (6–10) are *Scott's* current research preoccupation, not the *students'* question. A PhD student in Glasgow on Monday morning wants to know why she should care about the next 18 hours; APE answers a different question.

**Frame titles.** Most are assertions: "Sorting on δ can flip the sign of your answer"; "An estimand can be biased. A target parameter cannot." A few are labels ("Who am I?", "The data", "The four averages"). These are forgivable in a teaching deck — rhetoric_of_decks.md carves out "labeled setups." But "Who am I?" is a label where an assertion would land harder.

**Voice.** Consistent with Scott's substack and book. Contractions, em dashes, "Hold it.", honest acknowledgment of where the assumption is doing the work. The closing line ("two ingredients … together they identify the ATT") is exactly the substack-style honest punch.

### triple-diff.pdf — Day 2 morning (30 frames)

**What works.** Cleanest of the three. Slide 3 opens with the problem. The "two biased DiDs, one bias" framing (L2-F1 through L2-F3) is genuinely elegant — two DiDs with the same bias term, then subtract. The 8-cell cube (slide 9) is the right visual at the right moment. Gruber's own numbers landing close to the naive DiD (slide 17) and Scott naming this as "the wrong question" is exactly the right Popperian move.

**Frame titles.** Almost all assertions: "Gruber's move: bring in a third group"; "Subtract the bias — triple difference"; "What DDD does *not* require"; "When DDD is worse than DiD"; "Triple diff trades parallel trends for parallel bias." Strong throughout.

**Closing slide is broken** — see Major Concern 1.

### covariates.pdf — Day 2 afternoon (45 frames)

**What works.** Slide 4's "one false friend" framing for Lesson 4 is sharp. Lesson 4 itself (slides 17–22) is the strongest passage: temptation → what it actually assumes → simulation → code → weight-vs-regressor → name-the-disease. The "Name the disease: *additive-control-side bias*" slide (page 22) carries the central claim in one frame: Method B and TWFE-with-controls are the *same* mistake.

**Where the through-line frays.** Scott's ask: does the additive-control-side bias through-line across L2/L4/L5/L6 *land as one idea*, or read as three observations stapled together? **It lands at L4→L5 cleanly, frays at L6, and is rescued (partially) on L6-F5 (page 34)**. The fraying happens because L6-F3 (page 32) gives a *different* explanation of TWFE-with-controls bias — the FE transformation kills the levels of X and the time-invariant Z. That is a different mechanism from "additive RHS forces constant τ." The L4 mechanism is *functional form on the outcome side*; the L6-F3 mechanism is *what the within-transform throws away*. Both are in Caetano-Callaway. But the deck does not say "these are two separate biases that both afflict TWFE-with-controls." Page 22 connects L4 to L2; page 34 connects L4 to L6. Between them, slides 30–33 build the L6 story without referring back to L4. A PhD student can be forgiven for thinking the disease is "the FE transformation drops your X levels," with the L4 connection decorative. See Major Concern 3.

**L7 bridge slide.** Page 40 ("So why do we need Sant'Anna & Xu given Hong showed it?") works. The "estimand / test / estimator" trinity is the right way in. Quibble: the meta line at the bottom ("the story stays Hong's; the toolkit is new") is the punchline and would land harder as its own micro-slide. See Question 2.

**Closing slide is broken** — see Major Concern 1.

---

## Major Concerns

1. **Two of three closing slides are visually broken by the decorative TikZ rule.** The `\draw[accent, line width=1pt]` rule at `yshift=2.5cm` sits correctly on `basics.pdf` page 114 (reads as an underline). On `covariates.pdf` page 45 the rule slices *through* "two chances to be right." On `triple-diff.pdf` page 30 the centered text block overflows the top of the frame ("Triple diff trades parallel trends" is cut off above visible area) and the rule strikes through "DDD recovers the ATT." These are the slides the audience leaves remembering. Local fix: adjust `text width`, `fontsize`, or the rule's `yshift`. ~15 min per deck.

2. **basics.tex slides 2–11: eleven slides of meta-content before the first DiD assertion.** Slide 14 is where DiD starts. This violates "Lead with a problem" and substack_style.md ("Never open with an abstract claim"). Keep slide 2 (week shape), slide 12 (seven lessons), slide 14 (DiD is a design); collapse the other eight to at most three. Project APE is Scott's research, not the students' question. If Scott wants APE in, lead with the puzzle ("an LLM agent ran a DiD on castle.dta and got the wrong sign — why?") not a tour through David's project.

3. **Covariates L6 dilutes the through-line by introducing a second mechanism for TWFE-with-controls bias without flagging it.** Pages 22 and 34 explicitly claim Method B (L4) and TWFE-with-controls are the *same* identifying mistake — additive RHS forces constant τ. But pages 30–33 build the C&C application via a *different* mechanism — the within-transform drops levels of X and kills time-invariant Z. That is another disease that also afflicts TWFE-with-controls; it is not the same disease as L4. The slide that should land Scott's claim (page 34) has to do double duty — connect L4↔L6 and tell the audience the L6-F3 mechanism is separate from the L4 mechanism. It doesn't do the second job. Fix: add one slide before page 30 saying "TWFE-with-controls has two distinct problems: (i) the FE transformation drops what you wanted to control for; (ii) what's left enters additively, forcing constant τ. We'll cover (i), then connect (ii) back to Lesson 4." That re-establishes the through-line.

---

## Minor Concerns

1. **Snow caption (basics p. 25)** says "the treatment effect of clean water." Elsewhere the deck is religious about ATT vs ATE — should be "average treatment effect on the treated."

2. **Slide 12 / 113 redundancy.** "Today's seven lessons" (12) and "What we've done today" (113) are word-for-word the same list. Acceptable per rhetoric_of_decks.md teaching carve-out; a sentence-form closing recap would punch harder.

3. **basics p. 99 (weighted-PT simulation):** the embedded figure has annotation text at the bottom edge partially clipped against the image bounding box. Re-export with bottom margin, or shrink the `height` param ~5%.

4. **covariates p. 41 (SX: estimand/test/estimator).** Three stacked `\begin{block}` environments with `\scriptsize` body text. Below the 18pt floor in rhetoric_of_decks.md. Verify projector resolution before Tuesday.

5. **Font fallback noise.** All three logs report `T1/phv/m/it` → `T1/phv/m/sl` (italic→slanted Helvetica). Invisible at presentation distance; switch to `\usepackage[scaled]{helvet}` or TeX Gyre Heros to silence.

6. **basics p. 53 (heteroskedasticity).** 5-line bullet list + sandwich-estimator meta. Borderline two-ideas-per-slide; could be split into "what het is" + "how the sandwich handles it."

7. **covariates p. 13 (Abadie IPW).** Verbal description uses weight $p(X)/(1-p(X))$; the formula on the slide uses $(D - p(X))/(1 - p(X))$. Both are valid IPW-DiD weights but the description doesn't match the formula. Pick one.

---

## Questions for Authors

1. **Day 1 length.** 114 slides at ~3 min each is ~6 hours. Fine for code- and figure-heavy frames; too long for the eleven opening meta-slides. What is the actual session length? If shorter than 6 hours, the opening cull becomes more urgent.

2. **Hong→SX bridge (covariates p. 40).** Scott's specific ask: does the "estimand / test / estimator" trinity motivate SX given Hong? Yes — but the slide buries the punchline ("the story stays Hong's; the toolkit is new") in an italic footer. Promote to its own one-line frame after the trinity?

3. **Additive-control-side disease.** Is L6's "FE transformation drops levels" intended as the *same* disease as L4's "additive RHS forces constant τ"? My reading is they are two separate diseases that both afflict TWFE-with-controls. Confirm whether the through-line is "same mistake" or "TWFE has at least two distinct identifying problems."

---

## Verdict

[ ] Accept
[X] Minor Revisions
[ ] Major Revisions
[ ] Reject

**Justification:** Content is publishable as-is. Pedagogical rhythm is right more than it is wrong. Voice is consistent with Scott's substack and book. Compilation is clean. Two breaks worth fixing before Tuesday: the closing-slide visual defects (~30 min), and either a Day-1 opening re-cut (~60 min) or at minimum an honest framing decision (Question 4). The L6 through-line can be repaired in the room verbally if not on-slide, but a tighter on-slide revision lets the deck do the work without verbal scaffolding.

---

## Recommendations (priority, time)

1. **Fix the closing slides on covariates and triple-diff (30 min total).** Reduce closing text-block size or move the decorative rule below the text. Compare against basics.tex line 1835 — geometry there works.

2. **Cut Day 1 slides 3–10 from 8 to 3 (60 min).** Keep slide 2 and slide 12. Replace 3–11 with: (a) one you-slide, (b) one Claude-Code workflow note, (c) at most one APE slide — and if APE stays, lead with the puzzle, not the project description.

3. **Add the two-diseases slide before covariates L6 (15 min).** "TWFE-with-controls has two distinct problems. The FE transformation throws away levels (next four slides). And what's left enters additively, forcing constant τ (Lesson 4 callback)."

4. **Fix the Abadie IPW formula↔description mismatch on covariates p. 13 (5 min).**

5. **Promote the Hong→SX punchline to its own micro-slide (10 min).** "The story stays Hong's; the toolkit is new." One sentence, one frame, between L7-F3 and L7-F4.

6. **Optional for future iterations.** Re-cast remaining label titles as assertions ("Who am I?", "The data", "The four averages"). Split the heteroskedasticity slide. Re-export the weighted-PT simulation figure with bottom margin.

=================================================================
                      END OF REFEREE REPORT
=================================================================
