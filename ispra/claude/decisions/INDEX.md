# Binding Decisions

| ID | Decision | Date | Rationale |
|---|---|---|---|
| D01 | Real data only — Eurostat suicide SDR + World Bank unemployment; no simulation | 2026-06-04 | Findings will be shown to the European Commission; fabrication is disqualifying |
| D02 | Drop Finland (adopted 1992, pre-window) and France (suicide series starts 2001, no pre-period) | 2026-06-04 | Neither can contribute a pre-treatment baseline for CS estimation |
| D03 | Balanced panel: 16 countries with complete suicide + unemployment over 1994-2010 | 2026-06-04 | The `did` engine segfaults on the unbalanced panel; balancing avoids degenerate 2x2 cells |
| D04 | Regression adjustment (est_method="reg"), NOT inverse-propensity weighting | 2026-06-04 | The country-level propensity score perfectly separates treated from control; no common support |
| D05 | Condition on unemployment as the single covariate | 2026-06-04 | Imbens-Rubin std. diff = 0.33 (imbalanced); the dominant time-varying suicide confound (Ruhm; Reeves) |
| D06 | Universal (long-difference) base period for the event study | 2026-06-04 | Pre-period coefficients must be long differences from g-1, consistent with parallel trends and post-period coefficients; the short (varying) base manufactured a spurious pre-trend |
| D07 | Target parameter = group-size-weighted ATT | 2026-06-04 | Weights cohorts by number of treated countries (2:1:1); the requested estimand |
