# Audit 2 — Rhetoric (L6 & L7, `covariates.tex`)

Agent 2 of three independent auditors. Evaluating against Scott's rhetoric principles only — not substance.

---

## 1. Titles tally

**L6 (7 frames + section card):**
| # | Title | Verdict |
|---|---|---|
| F0 | "TWFE-with-controls has two distinct problems" | Assertion |
| F1 | "An applied problem you've already run" | Soft assertion / hook |
| F2 | "An application: stand-your-ground laws (Cheng & Hoekstra 2013)" | Label |
| F3 | "What TWFE actually controls for, after the FE transformation" | Label (sets up a question, doesn't answer it) |
| F4 | "What you should be controlling for" | Label (same pattern) |
| F5 | "The L4 callback: problem (2) is the additive-RHS disease" | Assertion |
| F6 | "The fix: AIPW with $(X_{t-1}, Z)$" | Assertion |
| F7 | "Stand-your-ground revisited — the numbers" | Label |

**L6: 4 assertions / 4 labels** (counting F1 as assertion).

**L7 (10 frames including punchline + bridge):**
| # | Title | Verdict |
|---|---|---|
| F1 | "Two flavors of '$X$ moves'" | Label |
| F2 | "Hong (2013): Napster, internet users, and music expenditure" | Label |
| F2b | "Hong (2013): the table that made the point" | Label |
| F2c | "Hong (2013): the figures" | Label |
| F3 | "So why do we need Sant'Anna & Xu given Hong showed it?" | Question (weak — should be the answer) |
| F3b | "The story stays Hong's. The toolkit is new." | Assertion (excellent) |
| F4a | "Sant'Anna & Xu: first, fix an estimand" | Label-ish (imperative) |
| F4b | "Second, test for compositional shift" | Imperative — label-tier |
| F4c | "Third, reweight and estimate" | Imperative — label-tier |
| F5 | "When compositional change matters in practice" | Label |

**L7: 1 assertion / 9 labels.** L7 is the weaker section by a wide margin.

---

## 2. Density flags (3+ ideas)

- **L6-F0** ("two distinct problems"): equation + 2 numbered claims, each with a sub-sentence. ~3 ideas. Borderline — but the two-problem framing is the unifying idea, so it earns the load.
- **L6-F2** (SYG application): 4 bullets + nested 3-row sub-bullet + 2-line block. **5+ ideas.** Slammed.
- **L6-F3**: 1 equation, transformation to second equation, 4 bullets explaining the consequence. **4 ideas.**
- **L6-F4**: 1 equation with 3 labeled braces + 3 bullets. **4 ideas.**
- **L6-F5** (L4 callback): 3-row table + 3 bullets + intro prose. **4–5 ideas.** Heaviest slide in L6.
- **L6-F7** (SYG numbers): 4-row table + 2 bullets. ~3 ideas. OK.
- **L7-F1**: 2-row table + 3 bullets. ~3 ideas.
- **L7-F3** (bridge): 1 question + 3 enumerated items. ~3 ideas — but appropriately structured.
- **L7-F4a**: pullquote + block + 2 bullets. ~3 ideas.

---

## 3. Application-first verdict: **FAIL for L7, PASS for L6**

- **L6 PASSES.** F1 opens with a pullquote ("TWFE with time-varying controls is the workhorse…"). F2 lands the SYG application immediately. The story arrives in slide 2 of the lesson. Good.
- **L7 FAILS.** F1 ("Two flavors of '$X$ moves'") is an abstract 2x2 table contrasting L6 vs L7 with estimator names. Hong doesn't appear until F2. The lesson should OPEN with "1996 Napster users were young, urban, technical — by 2002 they were everyone" and let the L6-vs-L7 distinction fall out of the contrast at the end. The current F1 is a synthesis slide misplaced as an opener.

---

## 4. Intuition-first verdict: **PASS for L6, PARTIAL for L7**

- **L6:** Story (SYG) → numbers shock (TWFE says +6.7%, AIPW says 0) → algebra (the FE transformation) → fix (AIPW). Correct order.
- **L7:** Hong narrative (F2) → table (F2b) → figures (F2c) → bridge (F3) is good. But then F4a opens SX with **"fix an estimand"** — an abstract technical move. The intuition for *why* you need a reference distribution is buried in one bullet. The estimand-test-estimator triplet (F4a/F4b/F4c) reads like a textbook section header, not a story. By the time the audience reaches "reweight," they've lost the Napster picture.

---

## 5. Beauty / where figures land

**Lands well:**
- L7-F2b (Hong table) and L7-F2c (two Hong figures side-by-side at 0.46\textwidth) — good size, prominent, captioned in warmgray italic. This is the rhetorical high point of L7.
- L7-F3b (the one-line punchline frame on cream background) — beautiful, breathes.
- Closing frame (regressor vs weight) — same.

**Visual deserts:**
- **SX (F4a/F4b/F4c) is entirely text.** Three consecutive frames of pullquote-block-bullets with zero visuals. After the visual peak of Hong, the audience hits a wall. F4b (Hausman test) is BEGGING for a two-panel cartoon: "naive DiD weight" vs "reweighted DiD weight" over an $X$ distribution.
- **L6 has zero figures.** All algebra and tables. The "TWFE positive effect collapses to zero" finding (F2 + F7) would land harder as a forest plot of the four specifications with error bars. The Caetano-Callaway paper has exactly that figure.
- **L6-F3/F4** (the algebra slides) could use a "what's struck through" annotation showing $Z_i$ and the level of $X$ being killed by the first-difference. Right now the disappearing terms live in prose bullets instead of being shown visually.

---

## 6. Tempo

**Longest text-only stretch:** L7-F3 → F4a → F4b → F4c → F5 = **5 consecutive text-only slides** after the Hong visuals end. This is the worst stretch in the deck. The F3b punchline frame interrupts only between F3 and F4a, not deep inside SX.

**Slammed slides:** L6-F2 (SYG application), L6-F5 (L4 callback table + bullets), L7-F1 (synthesis-as-opener).

**Underused slides:** none egregious. F3b and the closing frame are properly sparse.

**Breathing:** L6 has no plain-style breather frame. L7 has F3b. L6 would benefit from a parallel "hidden in plain sight" interlude between F4 and F5.

---

## Top 3 rhetoric fixes (ranked)

1. **L7-F1: replace "Two flavors of $X$ moves" with a Hong cold-open.** The current opener is an L6-vs-L7 synthesis table that only makes sense *after* both lessons. Move it to L7-F5 or cut it. Open L7 with a single image or one-line claim: *"In 1996, internet users were young, urban, technical. By 2002, they were everyone. Did Napster do that, or did the internet?"* This is the single biggest rhetoric problem in the rewrite.

2. **L7-F4a/F4b/F4c: break the text wall with one figure.** SX is the formal payoff of L7 and currently has no visual. Add a single two-panel cartoon at F4b showing the $X$ density shifting between pre and post, with the Hausman reweight arrow. Even a hand-drawn schematic would break the 5-slide text stretch.

3. **L6-F3 and F4 titles: convert from label to assertion.** "What TWFE actually controls for" → "TWFE controls for *changes* in $X$, not levels." "What you should be controlling for" → "Pre-period levels and time-invariant $Z$ belong on the right." Same content, but a reader of titles alone gets the argument. Currently L6's title sequence reads as a topic outline; the argument is hidden in the bodies.

---

*Total: ~640 words. Files audited: `covariates.tex` lines 917–1309 and rhetoric document.*
