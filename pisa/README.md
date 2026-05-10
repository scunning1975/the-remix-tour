# Pisa — Sant'Anna School Seasonal School (CME)

**Stop 4 of 7** · June 8–10, 2026 · Sant'Anna School of Advanced Studies, Pisa

17 academic hours over 3 days at the Sant'Anna Seasonal School "Causal Methods for Economics." This stop is distinctive on the tour for its use of **Claude Code** as a teaching environment for live coding.

---

## At a glance

| | |
|---|---|
| **Title** | Causal Inference with Micro Data |
| **Format** | 17 academic hours across 3 days (≈ 12–13 effective contact hours) |
| **Audience** | PhD students in economics + related quantitative disciplines (assumes linear regression, potential outcomes, basic panel data) |
| **Software** | **Claude Code** (live coding environment), R / Stata also welcome |
| **Track** | Micro track (companion macro track Jun 10–12 by separate instructor) |
| **Solo** | Yes |

---

## Day-by-day

### Day 1 — Mon Jun 8 · Foundations of Difference-in-Differences (~6 hrs)
- Potential outcomes framework; fundamental problem of causal inference
- Canonical 2×2 DiD: identification, parallel trends, estimation
- Pre-testing and diagnostics: event studies, placebo tests, covariate balance
- Introduction to Claude Code for causal inference workflows
- **Hands-on lab:** canonical DiD with real data using Claude Code

Time slots: 14:00–15:30 · break · 16:00–17:45

### Day 2 — Tue Jun 9 · Modern DiD with Staggered Adoption (~6 hrs)
- Problems with TWFE under staggered timing + heterogeneous effects
- Goodman-Bacon (2021) decomposition theorem; negative weighting
- Modern estimators: Callaway-Sant'Anna; Sun-Abraham; Borusyak-Jaravel-Spiess
- Aggregation schemes, event-study specifications, sensitivity analysis
- **Hands-on lab:** modern DiD vs. TWFE comparison using Claude Code

Time slots: 09:30–11:00 · break · 11:30–13:00 · lunch · 14:30–16:00 · break · 16:30–18:15

### Day 3 — Wed Jun 10 · Synthetic Control Methods (~5 hrs)
- Synthetic control: intuition, formalization, identification
- Inference: permutation (placebo) tests + conformal inference
- Augmented SCM (Ben-Michael-Feller-Rothstein); penalized SCM; synthetic DiD (Arkhangelsky et al.)
- **Hands-on lab:** build synthetic controls + conduct inference using Claude Code
- Wrap-up: choosing between DiD and SCM in practice; open Q&A

Time slots: 09:00–10:30 · break · 11:00–12:45

---

## Pedagogical approach

Three modes:
1. **Lectures** drawing on Cunningham (2021, 2026) and the primary research literature
2. **Live coding demos** using Claude Code — build estimation pipelines in real time
3. **Hands-on exercises** in which students replicate published results, diagnose specifications, and experiment with alternative estimators

The Claude Code integration is the distinctive feature — students focus on conceptual reasoning, not syntax, and walk away with reproducible code.

---

## Materials

- **`decks/`** — DiD foundations + Modern DiD + Synthetic Control (3 days of slides)
- **`labs/`** — Baker, Smoking, Synth, Augsynth, Synthdid (Claude Code-friendly)
- **`shiny_apps/`** — Bacon decomposition + event-study

---

## Hosts

- **Alessio Moneta** (Sant'Anna)
- Sant'Anna Seasonal School office

Program URL: <https://www.santannapisa.it/it/formazione/seasonal-school/cme>
