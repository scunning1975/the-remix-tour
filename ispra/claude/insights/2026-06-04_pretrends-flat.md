---
date: 2026-06-04
title: Pre-trends flat under the long-difference baseline
updates: H01a
result: confirmed
stage: [2]
script: code/R/analysis.R
output: output/figures/fig8_event_study.pdf
---

## Finding
With the **universal (g-1) baseline** — long differences, consistent with the parallel-trends
assumption — the joint pre-trend test does **not** reject: sum z^2 = 9.85 on 8 df (p≈0.30).
The earlier "violation" (sum z^2 = 59.4) was an artifact of the short (varying) baseline, which
computes each pre-coefficient as a one-period change rather than a cumulative deviation from g-1.

## Key Numbers
| Baseline | pre-trend sum z^2 (df 8) | verdict |
|---|---|---|
| varying (short diff) | 59.4 | spurious rejection |
| universal (long diff) | 9.85 | does not reject |

## Context
Post-treatment coefficients are identical across baselines. Caveat: with 4 treated countries the
test is powered only for gross violations — non-rejection is not strong confirmation.
