# Agent B — Student Walkthrough Audit

Pretending to be a first- or second-year PhD student who has run `reg` and made a graph in Stata, but never written a Monte Carlo. I went line by line.

## 1. Per-file readability scores

| File | Score | Reason |
|---|---|---|
| `basics/na.do` | 4.5 | Clean Y(0)/Y(1)/switching equation block (lines 47–71). Each `gen` is one move. Only ding: `egen att_c = mean(...)` followed by `su att_c att_d` is the "truth" but it isn't `display`-ed as the truth before the regressions run. |
| `event_studies/title_x_event_study.do` | 2.5 | The 10-line `trend` ladder (lines 43–51) is the lesson surfaced, good. But `y0` mixes county FE, AR(1) errors, and trend on one line (65). The student never sees an explicit "True ATT = …" `display`. The csdid calls show up with no narration of *what they should recover*. |
| `triple_diff/ddd2.do` | 3.5 | Strong: explicit Y(0), Y(1), `delta`, `treat`, switching equation, and the verbal eight-cell averages (lines 91–106) match how Scott talks. Weak: the `foreach y of numlist 1/10 { local year 2010 + y ... }` block at lines 37–40 is exactly the abstraction the style guide says to avoid. The final coefplot block (217–222) buries a giant control-set regression and uses regex rename — that line is a wall. |
| `covariates/comparing_did.do` | 4.5 | Best of the bunch. Section banners narrate the lesson, `display "True ATT = " r(mean)` is right at line 79, each estimator is in its own banner with a one-line interpretation of bias. The closing block (162–170) is a literal scoreboard. |
| `staggered/baker.do` | 3.5 | The 30 hand-written `replace year =` lines (28–57) ARE the lesson — that's the style guide working. Y(0)/Y(1) are visible (101–107). But `te1–te4` plus `te` then `te*treat*(year - treat_date + 1)` (line 107) is the most algebraically dense line in the corpus. The `coefplot` keep-list (122) is 40 hand-typed `dd` names — punishing. |

## 2. The "wait, what?" moments

- **`na.do`** — line 47: `gen y0 = firms + n + e`. Student asks: "what's `n`?" It was created at line 23 as `gen n=year` *before* `year` was overwritten to 1990–1993, so `n` is silently the integer 1–4 time index. That's a load-bearing trick that no comment flags.
- **`title_x_event_study.do`** — line 68: `gen y1 = y0 + post*treated*(year - 5)*0.6`. The student stops: where did 0.6 come from? What is the implied ATT? No `display` follows.
- **`ddd2.do`** — line 77: `gen att = `r(mean)'` immediately after `su delta if ...`. The student wonders why we `gen` a constant across all rows from `r(mean)` instead of just `display`-ing it. Then line 217 — the seven-way regression with `treated3##ib2014.year` — is the second stop.
- **`comparing_did.do`** — line 110: `reshape wide earnings, i(id treat age age_sq gpa gpa_sq) j(year)`. A student who has never reshape-wide'd a panel will fall off here, even though the conceptual move (differencing) is fine.
- **`baker.do`** — line 107: `gen y = firms + n + te*treat*(year - treat_date + 1) + e`. Three things multiplied with a date-arithmetic offset, no banner explaining "this is dynamic ATT growing linearly in event time."

## 3. Are the DGPs visible?

| File | Y(0) | Y(1) | Switching eq |
|---|---|---|---|
| `na.do` | line 47 (yes) | lines 50–57 (yes, two flavors) | lines 71–72 (yes) |
| `title_x_event_study.do` | line 65 (mixed) — FE + trend + AR(1) on one line | line 68 (yes but the magnitude is opaque) | line 71 (yes) |
| `ddd2.do` | line 64 (yes) | lines 71–72 (yes) | line 85 (yes) |
| `comparing_did.do` | lines 55, 60, 63–64 (yes, pre and post split) | lines 68–69 (yes) | line 84 (yes) |
| `baker.do` | line 101 (yes) | line 107 (yes but compound) | implicit via line 107 — no explicit `y = treat*y1 + (1-treat)*y0` |

`baker.do` is the only file where a student cannot point at a line and say "that's the switching equation." It's folded into the `y = firms + n + te*treat*(year - treat_date + 1) + e` line.

## 4. Are the truth values displayed?

- `comparing_did.do` — yes, line 79 `display "True ATT = " r(mean)`. Gold standard.
- `na.do` — partial. `su att_c att_d` (line 78) shows the truth but doesn't label it as truth.
- `ddd2.do` — partial. `su delta if after==1 & experimental==1 & worker==2` then `gen att = `r(mean)'` then `su att` — the student sees a number, but no `display "True ATT = -5000"` framing.
- `title_x_event_study.do` — **no.** The true ATT is buried in `post*treated*(year-5)*0.6`. Nothing is displayed before csdid runs.
- `baker.do` — **no.** True ATT(g,t) is implicit in `te*treat*(year - treat_date + 1)`; the student is never told what number to compare against.

## 5. Abstraction creep

- `ddd2.do` lines 37–40: the `foreach y of numlist 1/10 { local year 2010 + `y' - 1 ... }` is exactly the loop the README forbids. Compare to `baker.do` lines 28–57 which writes out all 30 years — same operation, different commitment.
- `ddd2.do` lines 111–120, 139–148, 185–199: cascades of `summarize ..., meanonly` / `local x = r(mean)` / arithmetic on locals. A student can follow each pair, but four nested locals plus a subtraction is programmer-y. A `display` of the eight cell means in a single block first would help.
- `title_x_event_study.do` line 61–62: `bys county_id: replace u = 0.7*u[_n-1] + rnormal(0,1) if year>1`. AR(1) recursion with `_n-1` indexing is unflagged and is a real concept the student hasn't seen.
- `baker.do` line 122: the `coefplot, keep(dd1 dd2 ... dd42)` enumeration. The variable list is 38 items typed by hand — fine — but the *omission* pattern (dd21 skipped, dd24 skipped) without comment is opaque.

## 6. One concrete fix per file

- **`na.do`** — add a comment on line 23: `gen n=year  // hold onto the 1..4 time index before we rename year to 1990..1993`. Then before the regressions, `display "Truth (constant TE) = 10. Truth (dynamic TE, averaged post) = 20."`
- **`title_x_event_study.do`** — split line 65 into three: a county-FE-only `y0`, then add the trend, then add the AR(1) shock. And insert before csdid: `su y1 y0 if treated==1 & post==1` and `display "True ATT (averaged) = " r(mean)` against `y1 - y0`.
- **`ddd2.do`** — replace the `foreach` block at 37–40 with ten explicit `replace year = 2010 if year==1` lines, matching `baker.do` and the README's worked example. Also add `display "True ATT = -5000"` after line 78.
- **`comparing_did.do`** — almost nothing to fix. Add a one-line banner above the `reshape wide` at line 110 explaining "we are widening the panel so we can take a single first-difference per person." That's the one move that loses non-coders.
- **`baker.do`** — add an explicit switching equation `gen y = (1-treat)*y0 + treat*y1` (after generating a separate `y1`), so the student can read "that's the switching equation" in one line. And replace the 40-name `coefplot keep(...)` with a comment explaining why dd21 and dd24 are dropped (the two leads).

## Summary

Two files clearly pass the student test: `comparing_did.do` (best — banners, displayed truth, named estimators) and `na.do` (clean DGP, just needs the truth labeled). Two files have one local fault each: `ddd2.do` (the forbidden `foreach` loop and missing truth display) and `baker.do` (the compound `y = …` line that hides the switching equation and the un-displayed truth). The weakest file is `title_x_event_study.do`: compound `y0`, undisplayed ATT, an AR(1) errors line that introduces `_n-1` indexing without warning, and csdid called before the student knows what number to look for.
