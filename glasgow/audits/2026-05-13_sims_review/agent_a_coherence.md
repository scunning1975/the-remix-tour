# Agent A — Pedagogical Coherence Audit

**Date:** 2026-05-12
**Scope:** `the-remix-tour/simulations/` — does the code teach the way the README claims?

## 1. Per-file scorecard

Commitments: (1) repetition over abstraction, (2) block-copy not function, (3) one step per line, (4) names you say out loud, (5) comments document lesson, (6) locals for storage not control, (7) display result, (8) section banners.

| File | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | Notes |
|---|---|---|---|---|---|---|---|---|---|
| `basics/na.do` | ✓ | ✓ | ✓ | warn | warn | ✓ | warn | fail | Banner only at top; no internal section banners. Names `y1_c`, `y1_d`, `delta_c` are terse, not spoken. Comments mostly LESSON-level but a few annotate syntax. Results emitted via inline `// did = 10` in regress comments rather than `display`. |
| `event_studies/title_x_event_study.do` | warn | ✓ | warn | warn | warn | ✓ | fail | warn | "Step 0a/0b/1/2" markers, not banner blocks. Compound generation in `treated = (...) | (...)`. `birth_rate = treated*y1 + (1-treated)*y0` is dense. No `display` of the truth or estimate. Trend block IS exemplary commitment-1 repetition. |
| `triple_diff/ddd2.do` | warn | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | One leftover `foreach y of numlist 1/10` (lines 37-40) to set years — directly contradicts commitment 1 (compare to `baker.do`'s 30 explicit replaces). Otherwise strongest banner-as-lecture-outline in the folder. `avg_wage_ame`, `att`, `non_pt` all spoken. `display` everywhere. |
| `covariates/selection.do` | fail | fail | warn | warn | fail | fail | warn | warn | The whole file is a `program define dgp` + `program define simulation`. This is the README's anti-pattern. Two `foreach` blocks. Comments annotate syntax (`// Fixed Effects Selection`). Locals used for control flow inside the program. Banners exist but they wrap programs, not lecture beats. |
| `covariates/comparing_did.do` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | Cleanest file in the folder by the README's own metric. Five estimators, five banners, each with a one-line plain-English lesson at the bottom. `display "True ATT = " r(mean)` and a final summary `display` block. No programs, no functions, no loops. |
| `covariates/covariates_monte_carlo.do` | fail | fail | warn | warn | warn | fail | warn | warn | Two `program define` blocks (`dgp`, `sim`), `simulate ... reps(1000)`. Necessary for a Monte Carlo, but exactly the abstraction style the README disallows. Two `twoway` blocks at the bottom — second one is unreachable dead code after `exit`. |
| `staggered/baker.do` | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ | warn | ✓ | The canonical example. 30 explicit `replace year =` lines (the README literally quotes this file's pattern). `dd1-dd23 dd25-dd48` is hand-written, not generated. Banner at line 93 reads as a lecture beat. Only weakness: estimates are read off regress output, not `display`-ed. |

Legend: ✓ pass · warn ⚠ partial · fail ✗ violated.

## 2. Strongest / weakest

**Strongest exemplar:** `comparing_did.do`. It hits all eight commitments cleanly, and the closing `display` block ("Naive DiD --- BIASED ...") reads exactly like a slide. **Runner-up:** `baker.do` — the file the README was clearly written from.

**Weakest:** `selection.do`. It is *structurally* the opposite of what the README asks for: two `program define` blocks, `foreach` over selection types, `matrix results = J(6,2,.)` populated by a loop, and a `file open/write/close` LaTeX builder that nests writes inside another loop pattern. A student who can read `comparing_did.do` cannot read this without learning four new Stata features first.

## 3. Are the 8 commitments coherent?

**Mostly yes, with two real tensions.**

- **Commitments 1 (no loops) and 6 (no abstraction via locals) vs. Monte Carlo necessity.** `simulate ... reps(1000)` *is* a loop. The README never acknowledges this. `selection.do` and `covariates_monte_carlo.do` both need programs to be simulated. The commitments as written outlaw the only files that compute distributions of estimators — which is half of what DiD pedagogy is *for*. A 9th commitment is missing: *"Monte Carlo wrappers are the one allowed abstraction; the DGP inside them follows commitments 1-8."* That is what `covariates_monte_carlo.do`'s `dgp` program almost does, but the DGP body itself uses `qui replace`, conditional `cond()`, and compound generation, so it doesn't.

- **Commitment 7 (display result) vs. commitment 3 (one step per line).** Stata's natural way to read a result is `r(mean)` from `summarize`, which is two lines: `su x` then `display r(mean)`. `baker.do` skips the `display` and lets `regress` print its own table. That's defensible but inconsistent.

**Missing commitment the files honor anyway:** *"End with the comparison between truth and estimate."* `na.do`, `ddd2.do`, `comparing_did.do`, and `selection.do` all do this — but the README never names it as a rule, only as a "how to use" note at the bottom.

## 4. Does `comparing_did.do` match the feel of `baker.do`?

Yes — and arguably exceeds it. Both have the banner-as-lecture-outline structure. Both write the DGP additively (`y0 = ... + ... + e`, then a separate `replace y1 = y0 + treatment effect`). Both close with a comparison the student can read. `comparing_did.do` is shorter because the design is a 2-period panel, but the *cadence* is the same: setup → DGP → truth → run estimators → tell the student what they just saw. The closing `display` block is something `baker.do` doesn't have and probably should.

One difference: `baker.do` writes 30 explicit `replace year` lines, `comparing_did.do` only writes 2 (1990, 1991). That's fine — the lesson doesn't require 30 years — but it means `comparing_did.do` can't be the file you point to as the canonical commitment-1 example. `baker.do` keeps that role.

## 5. The Monte Carlo — does it pass?

**No, not as written.** Specific failures:

- **`program define dgp` and `program define sim`** are the abstractions commitments 1 and 2 prohibit. Inside `dgp`, `qui replace y0 = unit_fe + 1000 + 200*age + 2000*gpa + e if year == 1991` is *the* compound generation the README forbids.
- **`gen propensity = 0.3 + 0.3 * (age > 0) + 0.2 * (gpa > 0)`** is three steps on one line.
- **`return scalar dripw = e(b)[1,1]`** uses position indices the student must decode from `drdid`'s help file. The README's commitment-4 test ("would Scott say this out loud?") fails for `e(b)[1,1]`.
- **The second `twoway` block (lines 163-179) is dead code after `exit`.** A student reading top-to-bottom will hit `exit`, but a student scrolling will be confused why there are two graphs. Delete or move to a comment.
- **Where it actually does conform:** the DGP body inside `dgp` *is* mostly one-step-per-line generation, centering, polynomial terms separately. The bones are right.

This is a CI-2 lab artifact that needs a deliberate pass to bring it into the style. It's not far — maybe 40 minutes of work.

## 6. Top 3 fixes for the worst-conforming file (`selection.do`)

1. **Inline the DGP.** Delete `program define dgp ... end`. Paste the body at the top of the file under a banner `**** Build the panel ****`. The Monte Carlo wrapper can stay (concession to commitment-9-that-should-exist), but the *contents* of the DGP must be readable top-to-bottom without entering a program.
2. **Replace `foreach type in anticipation benefit { ... }` with two explicit blocks.** Three selection mechanisms, three banner sections, three copies of the same ~10 lines with one suffix changed. This is exactly the README's "block-copy instead of function" example.
3. **Replace the LaTeX `file write` block with a `display` summary inside the .do file, and a separate `selection_table.tex` written by `esttab` or hand.** The current `file write mytable "...\\toprule" _n` cascade is unreadable; a student cannot tell what the final table will look like without mentally rendering 18 lines of escaped LaTeX. At minimum, add a `display` block first that shows the three columns of numbers — then the LaTeX is decoration, not the lesson.

A secondary fix worth flagging: rename `csdid_att_fe` → `att_csdid_fe`, etc. The current names break commitment 4 — Scott would say "the CSDID estimate of the fixed-effects-selection ATT," not "CSDID ATT FE."
