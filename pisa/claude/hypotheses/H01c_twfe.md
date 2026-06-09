---
id: H01c
title: TWFE is badly biased here
status: rejected
parent: H01
children: []
date_proposed: 2026-06-04
---

## Claim
The two-way fixed-effects estimate is distorted by negative weighting / forbidden comparisons.

## Courtroom
- Estimand: decomposition of the TWFE coefficient into 2x2 Goodman-Bacon components
- Falsification: large weight on already-treated-as-control comparisons

## Kills it
Forbidden comparisons carrying trivial weight, so TWFE approximates the heterogeneity-robust estimate.

## Evidence
- [[2026-06-04_bacon]] — forbidden comparisons get ~3% weight; TWFE 3.11 reconstructed exactly; TWFE ≈ CS. The estimator is not the problem.
