# Goodman-Bacon (2021), "Difference-in-differences with variation in treatment timing"

**Citation:** Goodman-Bacon, Andrew. 2021. "Difference-in-differences with variation in treatment timing." *Journal of Econometrics* xxx. https://doi.org/10.1016/j.jeconom.2021.03.014.

**Length:** 24 pages (single column, JoE article-in-press format).

**Source:** `pdfs/Bacon 2021.pdf`.

---

## 1. Research question

What does the two-way fixed effects (TWFE) DD estimator actually estimate when treatment timing varies across units? The canonical 2x2 DD is well understood; the multi-timing TWFE generalization is not. Bacon shows that the TWFE DD estimator is mechanically a weighted average of all possible 2x2 DDs in the data, and analyzes under what assumptions this weighted average has a causal interpretation.

The starting point is the canonical 2x2 (Eq. 1):

$$y_{it} = \gamma + \gamma_i \cdot TREAT_i + \gamma_t \cdot POST_t + \beta^{2x2} TREAT_i \times POST_t + u_{it}$$

The multi-timing generalization (Eq. 2):

$$y_{it} = \alpha_i + \alpha_t + \beta^{DD} D_{it} + e_{it}$$

with unit and time fixed effects and a single treatment indicator $D_{it}$.

## 2. The TWFE beta estimator in FWL form (Eq. 3)

By Frisch-Waugh-Lovell:

$$\hat{\beta}^{DD} = \frac{\hat{C}(y_{it}, \tilde{D}_{it})}{\hat{V}^D} = \frac{\frac{1}{NT}\sum_i\sum_t y_{it} \tilde{D}_{it}}{\frac{1}{NT}\sum_i\sum_t \tilde{D}_{it}^2}$$

where $\tilde{D}_{it} = (D_{it} - \bar{D}_i) - (\bar{D}_t - \bar{\bar{D}})$ is the fixed-effects-adjusted treatment dummy. This is the foundation: the TWFE DD coefficient is a covariance of $y$ with the demeaned treatment, normalized by the variance of the demeaned treatment.

## 3. The Decomposition Theorem (Theorem 1) — EXACT statement

> **Theorem 1 (Difference-in-Differences Decomposition Theorem).** Assume the data contain $k = 1,\ldots,K$ timing groups of units ordered by the time when they receive a binary treatment, $k \in (1, T]$. There may be one timing group, $U$, that includes units that never receive treatment. The OLS estimate $\hat{\beta}^{DD}$ in a two-way fixed-effects regression (2) is a weighted average of all possible two-by-two DD estimators.

$$\hat{\beta}^{DD} = \sum_{k \neq U} s_{kU}\, \hat{\beta}^{2x2}_{kU} \;+\; \sum_{k\neq U}\sum_{\ell > k} \left[ s^k_{k\ell}\, \hat{\beta}^{2x2,k}_{k\ell} + s^\ell_{k\ell}\, \hat{\beta}^{2x2,\ell}_{k\ell} \right] \quad \text{(10a)}$$

### The three 2x2 DD building blocks

**(10b) Treated-vs-untreated** — timing group $k$ vs the never-treated group $U$, $k$'s own pre/post split:
$$\hat{\beta}^{2x2}_{kU} \equiv \left(\bar{y}^{POST(k)}_k - \bar{y}^{PRE(k)}_k\right) - \left(\bar{y}^{POST(k)}_U - \bar{y}^{PRE(k)}_U\right)$$

**(10c) Early-vs-late, before $\ell$'s treatment** — earlier-treated $k$ is treatment, later-treated $\ell$ is **clean control during $\ell$'s pre-period**:
$$\hat{\beta}^{2x2,k}_{k\ell} \equiv \left(\bar{y}^{MID(k,\ell)}_k - \bar{y}^{PRE(k)}_k\right) - \left(\bar{y}^{MID(k,\ell)}_\ell - \bar{y}^{PRE(k)}_\ell\right)$$

**(10d) Late-vs-early, after $k$'s treatment** — later-treated $\ell$ is treatment, **already-treated $k$ is the control** (the "forbidden" comparison that breaks under time-varying effects):
$$\hat{\beta}^{2x2,\ell}_{k\ell} \equiv \left(\bar{y}^{POST(\ell)}_\ell - \bar{y}^{MID(k,\ell)}_\ell\right) - \left(\bar{y}^{POST(\ell)}_k - \bar{y}^{MID(k,\ell)}_k\right)$$

### The weights (Eqs. 10e-g)

Notation: $n_k$ is the sample share of timing group $k$. $\bar{D}_k$ is the share of periods group $k$ spends treated. $n_{ab} \equiv n_a/(n_a + n_b)$ is the relative size of two groups in a pair.

$$s_{kU} = \frac{(n_k + n_U)^2 \cdot \overbrace{n_{kU}(1-n_{kU})\bar{D}_k(1-\bar{D}_k)}^{\hat{V}^D_{kU}}}{\hat{V}^D} \quad \text{(10e)}$$

$$s^k_{k\ell} = \frac{\bigl((n_k + n_\ell)(1-\bar{D}_\ell)\bigr)^2 \cdot \overbrace{n_{k\ell}(1-n_{k\ell}) \frac{\bar{D}_k - \bar{D}_\ell}{1-\bar{D}_\ell}\frac{1-\bar{D}_k}{1-\bar{D}_\ell}}^{\hat{V}^{D,k}_{k\ell}}}{\hat{V}^D} \quad \text{(10f)}$$

$$s^\ell_{k\ell} = \frac{\bigl((n_k + n_\ell)\bar{D}_k\bigr)^2 \cdot \overbrace{n_{k\ell}(1-n_{k\ell}) \frac{\bar{D}_\ell}{\bar{D}_k}\frac{\bar{D}_k - \bar{D}_\ell}{\bar{D}_k}}^{\hat{V}^{D,\ell}_{k\ell}}}{\hat{V}^D} \quad \text{(10g)}$$

Weights are **strictly positive** and sum to one:
$$\sum_{k\neq U} s_{kU} + \sum_{k\neq U}\sum_{\ell>k}\bigl[s^k_{k\ell} + s^\ell_{k\ell}\bigr] = 1$$

### Pairwise subsample treatment variances (Eqs. 7-9)

These are the "amount of identifying variation" pieces that appear in the weights:

$$\hat{V}^D_{jU} \equiv n_{jU}(1-n_{jU})\bar{D}_j(1-\bar{D}_j) \quad (j = k, \ell) \quad \text{(7)}$$

$$\hat{V}^{D,k}_{k\ell} \equiv n_{k\ell}(1-n_{k\ell}) \frac{\bar{D}_k - \bar{D}_\ell}{1-\bar{D}_\ell}\frac{1-\bar{D}_k}{1-\bar{D}_\ell} \quad \text{(8)}$$

$$\hat{V}^{D,\ell}_{k\ell} \equiv n_{k\ell}(1-n_{k\ell}) \frac{\bar{D}_\ell}{\bar{D}_k}\frac{\bar{D}_k - \bar{D}_\ell}{\bar{D}_k} \quad \text{(9)}$$

First factor: how concentrated the timing groups are. Second factor: how variable $D_{it}$ is over time within each subsample. Variance is maximized when group sizes are balanced and when treatment occurs near the middle of the relevant window.

### Counting the components

With $K$ timing groups and one untreated group, the decomposition contains $K^2$ distinct 2x2 DDs: $K$ treated-vs-untreated terms, and $K^2 - K$ timing-only terms (paired $\hat{\beta}^{2x2,k}_{k\ell}$ and $\hat{\beta}^{2x2,\ell}_{k\ell}$). In the divorce application: 156 distinct DD components.

### Two-group "timing-only" estimator (Eq. 11)

A two-timing-group TWFE estimator is itself a weighted average of (10c) and (10d):

$$\hat{\beta}^{2x2}_{k\ell} = \underbrace{\frac{(1-\bar{D}_\ell)^2 \hat{V}^{D,k}_{k\ell}}{(1-\bar{D}_\ell)^2 \hat{V}^{D,k}_{k\ell} + \bar{D}_k^2 \hat{V}^{D,\ell}_{k\ell}}}_{\mu_{k\ell}}\, \hat{\beta}^{2x2,k}_{k\ell} + (1-\mu_{k\ell})\, \hat{\beta}^{2x2,\ell}_{k\ell}$$

$\mu_{k\ell}$ simplifies to $(1-\bar{D}_k)/(1-(\bar{D}_k - \bar{D}_\ell))$; falls as $\bar{D}_k \to 1$ (group $k$ treated earlier). The group treated closer to the middle of the panel gets more weight.

### Relation to other decompositions

- Strezhnev (2018) writes $\hat{\beta}^{DD}$ as an unweighted average across dyads of observations.
- Athey-Imbens (2018) decompose into terms by causal time horizon.
- Borusyak-Jaravel (2017) and de Chaisemartin-D'Haultfœuille (2020) decompose the **estimand** into a weighted average of treatment effects with potentially negative weights. Theorem 1 is different: it decomposes the **estimator** into simpler 2x2 estimators with strictly positive weights summing to 1.

## 4. Causal interpretation — population decomposition (Eq. 15)

Define $Y_{it}(k)$ = potential outcome under treatment date $k$; $Y_{it}(0)$ = untreated potential outcome. Group-time ATT (following Callaway and Sant'Anna 2020): $ATT_k(\tau) \equiv E[Y_{i\tau}(t^*_k) - Y_{i\tau}(0) \mid t_i = k]$. Average over window $W$ (Eq. 12):

$$ATT_k(W) \equiv \frac{1}{T_W}\sum_{t \in W} E[Y_{it}(k) - Y_{it}(0) \mid t_i = k]$$

Each 2x2 = ATT + differential-trends bias (Eqs. 14a-c):
- $\beta^{2x2}_{kU} = ATT_k(POST(k)) + [\Delta Y^0_k - \Delta Y^0_U]$ (clean)
- $\beta^{2x2,k}_{k\ell} = ATT_k(MID(k,\ell)) + [\Delta Y^0_k - \Delta Y^0_\ell]$ (clean control: $\ell$ untreated in MID)
- $\beta^{2x2,\ell}_{k\ell} = ATT_\ell(POST(\ell)) + [\Delta Y^0_\ell - \Delta Y^0_k] - [ATT_k(POST(\ell)) - ATT_k(MID(k,\ell))]$

The **extra bracketed term in (14c)** is the change in $k$'s treatment effect from MID to POST — this is what causes the trouble.

**Probability limit of TWFE (Eq. 15):**

$$\text{plim}_{N \to \infty} \hat{\beta}^{DD} = \beta^{DD} = VWATT + VWCT - \Delta ATT$$

where:

**VWATT (15a) — Variance-Weighted ATT, the causal estimand:**
$$VWATT \equiv \sum_{k \neq U} \sigma_{kU}\, ATT_k(POST(k)) + \sum_{k\neq U}\sum_{\ell > k}\bigl[\sigma^k_{k\ell}\, ATT_k(MID(k,\ell)) + \sigma^\ell_{k\ell}\, ATT_\ell(POST(\ell))\bigr]$$

All weights $\sigma$ (probability limits of decomposition weights) strictly positive, sum to 1.

**VWCT (15b) — Variance-Weighted Common Trends:** averages the differential-trend terms with the same weights. Generalization of common trends to the timing case.

**$\Delta ATT$ (15c) — bias from time-varying effects:**
$$\Delta ATT \equiv \sum_{k\neq U}\sum_{\ell > k} \sigma^\ell_{k\ell}\bigl[ATT_k(POST(\ell)) - ATT_k(MID(k,\ell))\bigr]$$

**$\Delta ATT$ is the source of "negative weights"** (Borusyak-Jaravel; de Chaisemartin-D'Haultfœuille; Sun-Abraham). It equals zero if treatment effects are time-invariant. Identification of VWATT requires $VWCT = 0$ AND $\Delta ATT = 0$. Always-treated units enter the decomposition exactly like never-treated units and can dominate $\Delta ATT$ if their effects evolve.

## 5. Weights as treatment vs control (Eqs. 16, 19; Fig. 4)

If effects vary across units but are constant over time, $\Delta ATT = 0$ and (Eq. 16):

$$VWATT = \sum_{k\neq U} ATT_k \cdot \underbrace{\Bigl[\sigma_{kU} + \sum_{j=1}^{k-1}\sigma^k_{jk} + \sum_{j=k+1}^{K}\sigma^k_{kj}\Bigr]}_{w^T_k}$$

where $w^T_k$ is the total weight group $k$ gets when it acts as a **treatment** group across all 2x2s.

**Linear pre-trend approximation (Eq. 19):**

$$VWCT \approx \sum_k \Delta Y^0_k \bigl[w^T_k - w^C_k\bigr]$$

where $w^C_k \equiv \sum_{j=1}^{k-1}\sigma^j_{jk} + \sum_{j=k+1}^{K}\sigma^j_{kj}$ is the total weight $k$ gets as a **control**. **A given group's differential trend biases the overall estimate signed by $w^T_k - w^C_k$.** Fig. 4: this is positive in the middle of the panel and negative at the ends — the earliest- and latest-treated groups effectively act as controls on net. In timing-only designs (no untreated group), the boundary groups *always* get more weight as controls than treatments.

## 6. Trend-break example (Fig. 3, Eqs. 17-18)

With effect $\phi(t - t_i + 1)$ and identical counterfactual trends:

$$\hat{\beta}^{2x2,\ell}_{k\ell} = \overbrace{\phi \tfrac{T-(\ell-1)}{2}}^{ATT_\ell(POST(\ell))} - \overbrace{\phi \tfrac{T-(k-1)}{2}}^{\Delta ATT/(1-\mu_{k\ell})} = \phi \tfrac{k-\ell}{2} \leq 0$$

Wrong-signed despite positive, growing treatment effects. This is why time-varying effects can flip the sign of a TWFE estimate.

## 7. Empirical replication: Stevenson and Wolfers (2006)

**Setting:** No-fault divorce reforms and female suicide. NCHS Multiple Cause of Death (1964-1996), 1960 Census + SEER denominators. 37 treated states, 14 controls (5 non-reform, 8 pre-1964 reform, 1969-1985 staggered cohorts). Outcome: age-adjusted female suicide rate per million women.

**Headline:** $\hat{\beta}^{DD} = -3.08$ (s.e. = 1.27 in figure; 1.13 in text), vs. Stevenson-Wolfers' log estimate of $-9.7$ (s.e. 2.3).

**Decomposition (Fig. 6):** 156 distinct 2x2 components. Timing-only weight = 0.37 (37 percent of variation is from timing); treated-vs-pre-1964-reform weight = 0.38, treated-vs-non-reform = 0.24, early-vs-late = 0.11.

- Average treated/untreated 2x2 effects: $-5.33$ (vs non-reform) and $-7.04$ (vs pre-1964 reform).
- Average early/late 2x2: $-0.19$.
- Average late/early 2x2: $+3.51$ (wrong sign — this is where $\Delta ATT$ bias comes from).
- Average post-treatment event-study coefficient: $-4.92$.
- Removing late/early terms yields $-5.44$, close to the event-study average.

**Conclusion:** TWFE estimate ($-3.08$) is 60% of the event-study average ($-4.92$). The bias is driven by positive late/early comparisons. Treatment effects grow over time, biasing TWFE upward (less negative) relative to VWATT.

## 8. Specification comparisons (Eq. 20, Table 2)

Bacon proposes a Oaxaca-Blinder-Kitagawa decomposition of differences across specifications:

$$\hat{\beta}^{DD}_{alt} - \hat{\beta}^{DD} = \underbrace{s'(\hat{\beta}^{2x2}_{alt} - \hat{\beta}^{2x2})}_{\text{Due to 2x2 DDs}} + \underbrace{(s'_{alt} - s')\hat{\beta}^{2x2}}_{\text{Due to weights}} + \underbrace{(s'_{alt} - s')(\hat{\beta}^{2x2}_{alt} - \hat{\beta}^{2x2})}_{\text{Due to interaction}}$$

Table 2 alternative specs (estimate, share-due-to: 2x2/weights/interaction/within):
- (1) Baseline: $-3.08$ [1.27]
- (2) No untreated states: $+2.42$ [1.81] (0/1/0/0) — sign flips because half the timing terms are biased
- (3) WLS by 1964 pop: $-0.35$ [1.97] (0.52/0.39/0.09/0)
- (4) Propensity-score weighted: $-1.04$ [1.78] (1/0/0/0)
- (5) Time-varying controls: $-2.52$ [1.09] (0.22/0.05/<0.01/0.73)
- (6) State-specific linear trends: $+0.59$ [1.35] (0.90/0.47/$-$0.36/0)
- (7) Group-specific pre-trends only (two-step): $-6.52$ [2.98] (1/0/0/0)
- (8) Region-by-year FE: $-1.16$ [1.37] (0.37/0.76/$-$0.13/0)

## 9. DD with time-varying controls (Section 5.2, Eqs. 21-27)

For $y_{it} = \alpha_i + \alpha_t + \Phi X_{it} + \beta^{DD|X} D_{it} + e_{it}$, the FWL form regresses on $\tilde{D}_{it} - \tilde{p}_{it}$ (where $\tilde{p}_{it}$ is predicted treatment from $\tilde{X}_{it}$). Bacon shows (Eq. 27):

$$\hat{\beta}^{DD|X} = \Omega\, \hat{\beta}^p_w + (1-\Omega)\sum_k\sum_{\ell > k} s^{b|X}_{k\ell}\, \hat{\beta}^{2x2|d}_{k\ell}$$

$\Omega$ = share of identifying variation from **within-timing-group** comparisons (units in the same timing group but with different predicted-treatment paths). Adding $X_{it}$ introduces a brand-new identifying comparison that didn't exist in the unadjusted regression. Bacon shows four ways controls can fail to remove bias and can introduce new bias instead.

## 10. Updated by subsequent work

Several elements of this paper have been revised or extended in later literature:

- **The decomposition weights have a cleaner representation in Callaway and Sant'Anna (2020/2021)** as aggregations of group-time ATTs $ATT(g,t)$. The Bacon weights correspond to a particular non-uniform aggregation rule.
- **The $\Delta ATT$ bias is also derived in de Chaisemartin and D'Haultfœuille (2020, AER)** and **Borusyak and Jaravel (2017) / Borusyak, Jaravel, Spiess (2024)** and **Sun and Abraham (2021)** with different parameterizations of the negative weights.
- **A Bacon-Goodman-Sant'Anna 2025 practitioner's guide** (forthcoming/online — title: roughly "Difference-in-Differences: A Practitioner's Guide") consolidates the staggered-DD landscape and likely revises the formal presentation, in particular emphasizing $ATT(g,t)$-based aggregation rather than the 2x2-decomposition representation. (I could not verify the exact paper from this PDF alone — it would need to be checked against the published version.)
- **The `bacondecomp` Stata module** (Goodman-Bacon, Goldring, Nichols 2019, SSC) implements the decomposition. An R port (`bacondecomp`) also exists.

## 11. Replication notes

- **Data sources:** NCHS Multiple Cause of Death files 1964-1996 (suicides by age/sex/state/year); 1960 Census (Haines/ICPSR) and SEER program for population denominators; Stevenson-Wolfers (2006) divorce-law dates.
- **Sample:** All states except Alaska and Hawaii.
- **Outcome:** Age-adjusted female suicide rate per million women (national female age distribution in 1964 as standard). Mean = 52/million (vs SW's 54).
- **Stata tools:** `bacondecomp` on SSC (Goodman-Bacon, Goldring, Nichols 2019).
- **Appendix:** `http://goodman-bacon.com/pdfs/ddtiming_appendix.pdf` (proofs of additional results, including DDD/triple-difference extensions and controlled 2x2 derivations).

## 12. Audience

DD practitioners across applied micro (labor, public, health, development, political economy). The paper is one of the foundational pieces of the 2018-2022 "staggered DD critique" along with de Chaisemartin-D'Haultfœuille (2020 AER), Borusyak-Jaravel (2017), Sun-Abraham (2021), Callaway-Sant'Anna (2021), Athey-Imbens (2018).

## 13. Contribution

1. First clean mechanical decomposition of TWFE DD estimator (not estimand) into strictly positive-weighted 2x2 building blocks.
2. Identification of "forbidden comparison" $\hat{\beta}^{2x2,\ell}_{k\ell}$ where already-treated units serve as controls — source of $\Delta ATT$ bias under time-varying effects.
3. New characterization of common trends in timing case via $w^T_k - w^C_k$.
4. Oaxaca-Blinder-Kitagawa tool for diagnosing why TWFE estimates change across specifications.
5. First detailed treatment of TWFE DD with time-varying covariates and the within-group identification it introduces.
