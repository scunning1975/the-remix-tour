# Synthesis — Pedagogical Style Audit (algebraic + simulation + voice)
**Date:** 2026-05-12
**Auditors:** Three independent agents, parallel
**Files audited:** `covariates.tex` (full deck), CI-2 `02-Covariates.tex` (benchmark), 5 Stata exemplars in `glasgow/labs/sims/`

## What the three agents converged on

The deck is rigorous but **less visceral than CI-2** in three specific ways:

1. **Algebraic patience has slipped** in a few high-value spots — conditional-PT identity is rushed; DR-DiD formula is stated not derived; no "add a zero" recognizable Scott move.
2. **Almost no simulations.** Only L4 (pscore trap) has a DGP companion. L2 (OR), L3 (IPW), L5 (DR), L6 (CC), L7 (SX) are taught algebraically with no DGP. The biggest miss: CI-2's 4-DGP Monte Carlo closer is **completely gone**.
3. **Voice fixes for the three risk spots are drafted and drop-in ready.**

But also: Agent C confirmed that L4 ("The Trap — Can't I just control for the pscore?") is **novel material that fills a real hole in CI-2** — CI-2 doesn't have a pscore-as-regressor trap section at all. The remix L4 is correct and an improvement.

---

## Priority 1 — drop-in ready (low effort, high leverage)

### A. Three "A student asks…" slides (Agent C drafted full LaTeX)

Insert points (lines per current `covariates.tex`):
- **After line 1058** (L6-F6 AIPW): *"A student asks: why $X_{t-1}$ and not $X_t$?"*
- **After line 1211** (L7-F4a SX estimand): *"A student asks: why pick the post-period treated population?"*
- **After line 1267** (L7-F4d Sequeira/SADC): *"A student asks: the Hausman test failed to reject — was SX even useful here?"*

Each uses `\pullquote{...}{A student, raising a hand}` — the convention already in use at L4-F1, L7-F0, L7-F4a. No new macros needed. Drop-in ready from `agent_c_voice_and_trap.md`.

### B. Restore the 4-DGP Monte Carlo closer (Agent B's #1)

CI-2 closes L6 with a Monte Carlo: 10K reps × n=1000, comparing **TWFE / OR / IPW / DR** on **Bias / RMSE / SE / Coverage / CI-length** across 4 DGPs. The .do/.R code already exists at `glasgow/labs/sims/covariates_monte_carlo.{do,R}`. The figures `mc_dr_1.png` and `mc_dr_2.png` are already in `glasgow/decks/figures/`. Estimated effort: 6 slides, no new code or graphics.

**Why this matters:** DGP4 (neither OR nor pscore correct) shows DR has nontrivial bias — keeps the deck honest. The DR section currently sells "two chances to be right" without showing what happens when both are wrong.

---

## Priority 2 — medium effort, high leverage

### C. Expand step 1 of the proof + split DR-DiD (Agent A's #1 and #2)

- **Step 1 (covariates.tex line ~247):** Rebuild the conditional-PT identity with 3–4 explicit rearrangement lines + `\underbrace{}` labels, mirroring CI-2 lines 684–688.
- **DR-DiD (lines ~811–826):** Split the current single frame into TWO:
  - Frame A: glossary — what is $\mu_{d,\Delta}$? what is $p(X)$? where is the Hájek normalization?
  - Frame B: assembled formula + the "control for $X$ twice" line (CI-2 line 629 verbatim — Scott's signature phrasing).

### D. Stata companion to the PT-on-Y⁰ sim (Agent B's critique)

The current PT-failure sim is in R only. Every other `glasgow/labs/sims/` exemplar is Stata. Add a `.do` companion + add one line that prints the *truth contrast* (DiD reads ≈1 when ATT = 0) so the bias is manifest in Scott's style.

---

## Priority 3 — bigger lift but worth it if time allows

### E. New simulation slides for L5 (DR) and L6 (CC)

- **L5 DR "either-model" sim** (Agent B's #2): two scenarios — misspecify outcome only / misspecify pscore only. Table showing DR row sits at truth in both. Single-slide demonstration of why DR matters.
- **L6 CC hidden-linearity toy** (Agent B's #3): DGP where Stand-Your-Ground has known ATT = 0. TWFE returns +0.067; AIPW with $X_{t-1}$ returns ≈0. Single slide turns the empirical numbers (currently presented as a found result) into a controlled experiment.

### F. "Add a zero" derivation slide in L2 (Agent A's #3)

Scott's most recognizable algebraic move (from CI-1 01-Basics.tex lines 541–554). Currently absent from the Glasgow covariates derivation. A single slide showing the move (add zero, rearrange, identify ATT in terms of observables) would re-establish the signature.

---

## What we should NOT do

- **Do not add an L7 compositional-change simulation.** Agent B explicitly recommends against — Hong's empirical figures already do the visceral work, and the SX DGP is hard to make punchy in one screen.
- **Do not change L4 ("The Trap").** It's already novel and correct. Optional Słoczyński slide flagged by Agent C is take-it-or-leave-it; L4 stands without it.

---

## Estimated impact

If we ship Priority 1 (A + B) only: **9 new slides** (3 "A student asks" + 6 Monte Carlo). High-leverage, low effort. Deck goes from 74 → ~83 pages.

If we ship Priority 1 + Priority 2: **add ~3 more slides** (proof step 1 rebuild, DR-DiD split, .do companion). ~86 pages.

If we ship all three priorities: **add ~6 more slides** (DR sim, CC sim, "add a zero"). ~92 pages.

At 92 pages, this is a full-afternoon block. The cap is your tolerance for length on Wednesday.

---

## Recommended commit-or-skip decisions

| Item | Lift | Leverage | Recommendation |
|---|---|---|---|
| 3× "A student asks…" slides | Trivial (drafted) | High | **Ship** |
| Monte Carlo closer | Low (code exists) | Highest | **Ship** |
| Step 1 expansion | Low | Medium | Ship if time |
| DR-DiD split | Low | Medium | Ship if time |
| PT-on-Y⁰ Stata companion | Low | Medium | Ship if time |
| L5 DR sim | Medium | Medium | Optional |
| L6 CC toy sim | Medium | Medium | Optional |
| "Add a zero" slide | Low | Low (style only) | Optional |

---

## Status

- Five Stata simulations saved to `glasgow/labs/sims/` (durable artifacts for students).
- Monte Carlo figures (`mc_dr_1.png`, `mc_dr_2.png`) migrated to `glasgow/decks/figures/`.
- Three agent reports written and converged.
- No deck file modified yet.

Awaiting Scott's call on which priorities to ship.
