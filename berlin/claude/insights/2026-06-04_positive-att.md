---
date: 2026-06-04
title: Adoption is followed by MORE suicide (+2.7/100k)
updates: H01
result: complicated
stage: [4]
script: code/R/analysis.R
output: output/figures/fig8_event_study.pdf
---

## Finding
The group-size-weighted ATT of strategy adoption is **+2.73 suicides per 100,000** (s.e. 1.05) —
positive, not protective. Three heterogeneity-robust estimators agree: CS +2.7, BJS +3.2, SA +3.0.

## Key Numbers
| Estimator | ATT | SE |
|---|---|---|
| Callaway-Sant'Anna (reg, +unemp) | +2.73 | 1.05 |
| Borusyak-Jaravel-Spiess | +3.23 | 1.30 |
| Sun-Abraham | +3.03 | 1.38 |

## Context
N=272 (16 countries, 4 treated), 1994-2010. The sign is the opposite of the literature's protective
claim — but see H01b: it is not causal.
