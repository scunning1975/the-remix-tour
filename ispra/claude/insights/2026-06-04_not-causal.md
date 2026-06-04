---
date: 2026-06-04
title: The positive estimate is not causal
updates: H01b
result: rejected
stage: [3, 4]
script: code/R/analysis.R
output: output/figures/fig9_honestdid.pdf
---

## Finding
The +2.7 estimate fails every credibility check: Rambachan-Roth cannot sign it under modest trend
violations; the in-space placebo p = 0.25 (indistinguishable from random fake adoption among
controls); dropping the four post-communist controls nearly halves it to +1.24; and it loads on the
2008 recession in calendar time. Synthetic control (UK, IE) gives placebo p = 0.46 / 0.69.

## Key Numbers
| Check | Result |
|---|---|
| Rambachan-Roth robust CI | spans zero |
| In-space placebo p | 0.25 |
| Drop post-communist controls | +2.7 -> +1.24 |
| Synthetic control placebo p | 0.46 (UK), 0.69 (IE) |

## Context
Conclusion: the cross-national design cannot identify the effect. Not protective, not proven harmful — undetermined.
