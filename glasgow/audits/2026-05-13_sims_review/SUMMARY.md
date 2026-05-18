# Synthesis — Simulations Review + Deck Integration
**Date:** 2026-05-13
**Auditors:** 3 independent agents (coherence, student-walkthrough, deck integration)
**Files audited:** `simulations/` (8 files + README) + `covariates.tex` code blocks and figures

## What the three agents converged on

The new `comparing_did.do` lands cleanly — Agent A scores it 8/8 on the commitments, Agent B scores it 4.5/5 on student readability. **It's the new gold standard.** But three real issues surfaced:

### 🚨 The 8 commitments have a structural gap

Agent A's catch: commitments 1 and 6 (no loops, no abstracting locals) **literally outlaw the abstraction a Monte Carlo needs**. So `selection.do` and `covariates_monte_carlo.do` *look like* they violate the rules even though Monte Carlos genuinely need wrapper functions. Fix: add a **9th commitment** to the README:

> *"Monte Carlo wrappers are the one allowed abstraction. The DGP inside them still follows 1–8."*

And a missing commitment the files actually honor that the README doesn't name: **end with the truth-vs-estimate comparison.** `comparing_did.do` closes with a display block ranking the estimators against the truth. That move is the punchline of every simulation. Should be commitment 10.

### ⚠️ Style violations even in canonical files

Both auditors caught the same two:
1. **`ddd2.do` lines 37–40** uses `foreach y of numlist 1/10 { ... }` to assign year labels. This **directly violates commitment 1**. Trivial fix: write 10 explicit `replace year = 2010 if year==1` lines, the way `baker.do` does for 30.
2. **`baker.do` line 107** folds the switching equation into a compound `gen y = firms + n + te*treat*(year - treat_date + 1) + e`. A student can't point at one line and say "that's the switching equation." Should be split: `gen y0 = firms + n` / `gen te_dynamic = te*treat*(year - treat_date + 1)` / `gen y = y0 + te_dynamic + e`.

### ❌ Truth-display gaps

Agent B's report card on whether each file `display`s the truth ATT before running estimators:

| File | Truth displayed? |
|---|---|
| `comparing_did.do` | ✓ (line 79: `display "True ATT = " r(mean)`) |
| `na.do` | ~ (`su delta_c` shows the number but doesn't label it as the truth) |
| `ddd2.do` | ~ (same — computes ATT but doesn't display it before estimators) |
| `title_x_event_study.do` | ✗ (ATT magnitude hidden in `(year-5)*0.6`) |
| `baker.do` | ✗ (never displays true ATT) |
| `selection.do` | ~ (computes inside Monte Carlo wrapper but not visible to student) |

**Fix:** add a `display "True ATT = ..."` line right after the DGP and right before the first estimator in each file.

### ❌ Worst file: `selection.do`

Agent A: structurally the opposite of the README — uses `program define`, `foreach`, locals-as-control-flow, `file write` LaTeX cascade. **Rewriting it would be substantial.**

### ❌ Hardest "wait, what?" moment in the corpus

Agent B: `baker.do` line 122 — 40 hand-typed `dd` names in `coefplot keep(...)` with `dd21`/`dd24` silently dropped (no comment that those are the two omitted leads). Student wouldn't catch why.

### ⚠️ Figure aesthetic gap

Agent C: the **`mc_dr_1.png` and `mc_dr_2.png`** carried over from CI-2 use ggplot defaults (gray panel, no remix palette). They clash with the cream-background TikZ frames around them. Same likely true for `pt_fails_in_y0.pdf` and `ipw_comparison.pdf` (need to spot-check).

**Concrete fix:** regenerate using `source("_themes/remix_theme.R")` + `theme_remix(legend="bottom")` + `scale_fill_remix_d()` + `remix_save()`. Hong's published PDFs are unavoidably out of style — leave them. But everything we generate ourselves should be in our aesthetic.

### ✓ Code blocks in the deck are fine

Agent C: the three `\begin{lstlisting}` blocks in `covariates.tex` are already stripped-down. L4's IPW code block (line 703) is the model. No code-block remediation needed.

### ⚠️ Breadcrumb pattern is inconsistent

Agent C: `\meta{simulations/...}` exists at L4-F4, L5-MC1, L5-MC6, Lab — but missing from L2-F2j (PT-fails sim), L2-F2l (Spec A vs B), L5-F5 (DR-DiD code), and L5-MC2/MC4 (MC results tables). Adding 4–5 one-line `\meta{}` references would tie every slide with code back to its file.

---

## Prioritized fix list (8 items)

| # | Item | Effort | Leverage | Recommendation |
|---|---|---|---|---|
| 1 | Add commitments 9 + 10 to `simulations/README.md` | Trivial | High | **Ship** |
| 2 | Fix `ddd2.do` lines 37–40 (replace foreach with 10 explicit lines) | Trivial | Medium | **Ship** |
| 3 | Split `baker.do` line 107 compound `gen` into 3 lines | Trivial | Medium | **Ship** |
| 4 | Add `display "True ATT = ..."` to title_x, baker, na, ddd2 | Low | Medium | **Ship** |
| 5 | Regenerate `mc_dr_*.png` using `remix_theme()` | Low (recipe exists) | **High** | **Ship** |
| 6 | Audit `pt_fails_in_y0.pdf` and `ipw_comparison.pdf` for aesthetic match; regenerate if needed | Low | Medium | Ship if needed |
| 7 | Add `\meta{simulations/...}` breadcrumbs to 4–5 deck slides | Trivial | Medium | **Ship** |
| 8 | Rewrite `selection.do` to follow the 8+2 commitments | Medium-high | Medium | Optional / later |

---

## What this commits us to going forward

Every new Stata or R file gets held to **10 commitments** (the original 8 + Monte Carlo exception + truth-vs-estimate closer). Every new figure goes through `remix_theme()`. Every slide that demonstrates an estimator gets a `\meta{simulations/...}` breadcrumb. The README is the appeal mechanism.

If we ship items 1–5 and 7, the simulations folder + the deck both become **self-consistent** in style — a student opening any file or any slide encounters the same aesthetic and the same teaching rhythm.

---

## Status

- All three agent reports written (under audits folder).
- No simulation files modified yet.
- No deck files modified yet.
- Awaiting Scott's call on which items to ship.
