# Findings — single source of truth

**Question.** Did national suicide-prevention strategies reduce suicide? A staggered-adoption
re-analysis of European countries, 1994–2010, with heterogeneity-robust estimators.

**Data (all real).**
- Outcome: Eurostat `hlth_cd_asdr` — age-standardised suicide rate (intentional self-harm,
  ICD-10 X60–X84,Y870), per 100,000, country-level, 1994–2010.
- Treatment: government-adopted *standalone* national suicide-prevention strategy
  (WHO 2018 criterion; cross-checked Lewitzka et al. 2019). In-window adopters:
  Norway 1995, Sweden 1995, **UK 2002, Ireland 2005**. France (2000) dropped — suicide series
  starts 2001, no pre-period. Finland (1992) dropped — pre-window.
- Covariate: World Bank unemployment rate (modeled ILO) — dominant time-varying suicide confound.
- Documented **never-treated controls** (WHO 2018): Germany, Italy, Spain, Belgium, Austria,
  Switzerland, Netherlands, Portugal, Greece, Luxembourg, Czechia, Estonia, Hungary, Slovenia (and others).

**Estimation sample.** Balanced panel, 16 countries × 17 years = **272 obs**, 4 treated, 12 never-treated.
Cohorts: 1995 (NO, SE), 2002 (UK), 2005 (IE).

**Why regression adjustment, not IPW.** Country-level propensity score perfectly separates
(treated ≈ 1, controls ≈ 0): no common support. We use Callaway–Sant'Anna with
**regression adjustment** on unemployment; DR/IPW reported only as robustness.

**Headline (group-size-weighted ATT, the chosen target parameter):**
| Estimator | ATT (suicide per 100k) | SE |
|---|---|---|
| Callaway–Sant'Anna (reg, +unemp) | **+2.73** | 1.05 |
| CS simple average | +3.05 | 1.24 |
| CS doubly-robust | +2.56 | — |
| CS unconditional | +2.76 | — |
| CS not-yet-treated control | +2.66 | — |
| Borusyak–Jaravel–Spiess (imputation) | +3.23 | 1.30 |
| Sun–Abraham | +3.03 | 1.38 |

All estimators **agree**: suicide is ~2.7–3.2 per 100k **higher** after adoption.

**This is NOT causal. The design fails:**
1. **Pre-trends violated** — ∑z² = 59.4 on 8 df (p≪0.001). Suicide is already elevated/rising
   in adopters before adoption (CS e=−8: +2.29; BJS pre-coefs +1.7 to +4.0). Strategies are
   adopted *because* suicide is high → reverse causation / Ashenfelter dip.
2. **Calendar confound** — later cohorts' post-windows sit on the 2008 Great Recession
   (the textbook suicide shock; Reeves et al. 2012). Calendar-time ATT loads post-2008.
3. **Rambachan–Roth** — under even mild relative-magnitude violations the robust CI for the
   ATT includes everything; the effect cannot be signed.
4. **In-space placebo** p = 0.25 — the observed ATT is well within the distribution from
   random fake adoption among controls.
5. **Synthetic control (UK, IE)** — placebo p = 0.46 (UK), 0.69 (IE); post-gaps indistinguishable
   from control placebos and confounded by the recession. NO/SE infeasible (1 pre-period).

**Conclusion (honest).** After two decades and dozens of national strategies, the cross-national
observational record **cannot identify** whether suicide-prevention strategies saved lives. The
naive "more suicide after adoption" estimate is an artifact of *when* countries adopt (when
suicide is already climbing) and *when* their post-periods fall (the recession). The famous
protective TWFE estimates (Matsubayashi & Ueda 2011) do not survive heterogeneity-robust
scrutiny. This is not evidence that strategies fail — it is evidence that we have been governing
life and death on a design that collapses under inspection.

**Title (Weitzman style, no colon):** *The Arithmetic of Despair*  [working — see candidates in paper]

**Key figures:** fig4 panelview · fig5 cohort counts · fig6 outcome-by-cohort · fig3 pscore separation ·
fig8 CS event study · fig8c calendar-time · fig9 Rambachan–Roth · fig_robust_overlay (3 estimators) ·
fig_falsification_placebo · fig_synth_{fit,gap,spaghetti,rmspe}_{UK,IE}.
