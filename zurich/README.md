# Zurich — UZH Topics in Causal Inference

**Stop 1 of 8** · May 11–13, 2026 · University of Zurich, Department of Economics

A 3-day PhD course on the **frontiers of new panel methods** — taught by Scott Cunningham at UZH. (Daniel Rees teaches a separate 1-day Hidden Curriculum workshop on Thu May 14.)

---

## Course title and description

> **"Advanced Topics in Applied Causal Inference"** *(working title — alt: "Topics in Causal Inference")*
>
> Causal inference is regularly evolving, and at a pace fast enough that requires regular investments. This weeklong course will cover the **frontiers of new panel methods**. Students will gain a deeper understanding of difference-in-differences, both theoretically and in its application.

*(Description per Scott's Nov 17, 2025 email to Roberto Weber. Mini-course assessment is pass/fail; format under discussion with Dan.)*

---

## At a glance

| | |
|---|---|
| **Format** | 3 full days (Mon–Wed), 6 lessons/day = 18 lessons total |
| **Audience** | UZH GSE PhD students (mix taking-for-credit and auditors) |
| **Software** | R + Stata |
| **Solo** | Yes — Scott teaches the mini-course alone. Daniel Rees teaches the separate Hidden Curriculum workshop on Thu May 14. |

---

## Schedule

| Day | Time | Room | Address |
|---|---|---|---|
| Mon May 11 | 9:00–12:00 | SOE-E-8 | Schönberggasse 11 |
| Mon May 11 | 15:00–18:00 | SOE-F-2 | Schönberggasse 11 |
| Tue May 12 | 9:00–12:00 | KOL-G-217 | Rämistrasse 71 |
| Tue May 12 | 13:00–15:45 | KOL-G-217 | Rämistrasse 71 |
| Wed May 13 | 9:00–12:00 | KOL-G-217 | Rämistrasse 71 |
| Wed May 13 | 13:00–15:45 | KOL-G-217 | Rämistrasse 71 |

---

## Scope and topic arc

The course is **panel-methods-first** — DiD, modern DiD, synthetic control, and recent extensions. Cross-sectional methods (RDD, IV, broad matching) are deliberately **not** the focus; only the cross-sectional content that's directly relevant to DiD and synth is included.

### Foundations included (selectively)
Just enough to set up the panel methods cleanly:
- **Potential outcomes** — ATT/ATE/LATE; identification vs. estimation
- **Regression** — review for DiD baselines
- **Bias adjustment / Abadie-Imbens** — nearest neighbor matching with bias correction (used as a step into modern DR-DiD)
- **Propensity scores + overlap / common support** — sets up doubly-robust DiD and weak-overlap discussions

### Day 1 — DiD foundations
- Canonical 2×2 DiD; parallel trends; pre-testing
- The Roth-Sant'Anna question: **when is parallel trends sensitive to functional form?** ([ECTA19402](https://psantanna.com/files/ECTA19402.pdf))
- The Goodman-Bacon-Sant'Anna-Whitten question: **when should we (not) worry about parallel trends?** ([GSW 2026 AEA P&P](https://psantanna.com/files/GSW2026_AEAPP.pdf))

### Day 2 — Modern DiD
- Goodman-Bacon decomposition; problems with TWFE under staggered adoption + heterogeneous effects
- Callaway-Sant'Anna; Sun-Abraham; Borusyak-Jaravel-Spiess
- **DR-DiD under weak overlap** (Sant'Anna [DR_WeakOverlap](https://psantanna.com/files/DR_WeakOverlap.pdf))
- **Time-varying covariates in DiD** — the Caetano-Callaway covariates paper ([arXiv:2406.15288](https://arxiv.org/abs/2406.15288))
- **Triple difference + overlap violations** (Sant'Anna [DDD_OVS](https://psantanna.com/files/DDD_OVS.pdf))

### Day 3 — Synthetic Control + frontier
- Abadie-Diamond-Hainmueller; permutation + conformal inference
- Augmented and penalized SCM; synthetic difference-in-differences
- **Continuous-treatment DiD** (Callaway-Goodman-Bacon-Sant'Anna) — pair with the **`baconplus`** shiny app for the weight-decomposition view
- **DiD under compositional changes** (Sant'Anna [DiD_CC](https://psantanna.com/files/DiD_CC.pdf)) — complements the Hong (2011) Netflix paper

---

## Materials

- **`decks/`** — compiled slide PDFs (foundations + DiD + synth)
- **`labs/`** — R + Stata labs (Lalonde for matching/bias adjustment intuition, Baker for staggered DiD diagnosis, Synth)
- **`shiny_apps/`** — Bacon decomposition, event-study explorer

See subfolder READMEs for content details. Readings catalog at [`../readings/`](../readings/) — particularly the **DiD frontier** section.

---

## Hosts

- **Roberto A. Weber** (UZH Econ — engagement)
- **Ulf Zölitz** (Jacobs Center, UZH — faculty host)
- **Mirjam Britschgi-Wendel** (UZH Econ — PhD program coordinator)
