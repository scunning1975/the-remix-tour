# Agent B — Simulation Audit of `covariates.tex`

Scott's exemplars (`na.do`, `selection.do`, `comparing.do`, `covariates_monte_carlo.do`) all follow the same five-beat pattern: set seed → build `y0` explicitly → build `y1 = y0 + δ` → switching equation → compute truth (`su delta if treat==1 & year>=1991`) → run estimators → display bias. The deck currently has one such block (L2 PT-on-Y⁰). The other six lessons are pure algebra.

---

## 1. Gap inventory by lesson

| Lesson | Concept | DGP companion? |
|---|---|---|
| L2 (OR) | Heckman-Ichimura-Todd impute counterfactual | **Missing.** Algebra only; no `\hat\mu_0(X)` shown beating biased TWFE. |
| L3 (IPW) | Abadie 2005 reweight controls | **Missing.** Proof slide, no DGP. |
| L4 (pscore trap) | Method A vs Method B | **Present** — `ipw_comparison.pdf` is in figures/. Codeblock + result. Only fully-served lesson besides PT-on-Y⁰. |
| L5 (DR) | Either-model-correct | **Missing.** Identity proven; never *shown*. The DGP that earns the "two chances" punchline doesn't exist in the deck. |
| L6 (CC hidden linearity) | FE drops levels; X_{t-1} fix | **Missing.** SYG numbers shown, but no controlled DGP where the truth is known. |
| L7 (SX compositional) | Hong → SX target | **Missing.** Hong figures imported; no toy DGP of the compositional shift. |

---

## 2. Proposed simulations (specific enough to code)

### L2-Sim: OR beats additive-X TWFE when τ(X) is heterogeneous

**DGP.** 1,000 workers, 2 periods. `x = rnormal(0,1)`. `treat = (rnormal() + 0.5*x > 0)`. `y0 = 10 + 2*x + t + e`. `y1 = y0 + 1 + 0.5*x` (heterogeneous τ).
**Truth.** `su delta if treat==1 & post==1` → ATT ≈ 1 + 0.5·E[x|treat]. Compute explicitly.
**Comparison.** TWFE-with-additive-X (biased — forces constant τ) vs. OR fit on controls only with `\hat\mu_0(x) = a + bx`, then `mean(ΔY - \hat\mu_0(X))` on treated (unbiased).
**Visualization.** Two-column table: Estimator | Estimate | Truth | Bias. One line per estimator.

### L3-Sim: IPW beats TWFE when ΔY is X-dependent

**DGP.** `x = runiform(0,1)`. `treat = rbinomial(1, 0.2 + 0.6*x)` (selection on X). `y0_pre = e`, `y0_post = 2 + 3*x + e` (untreated trend depends on x). `y1_post = y0_post + 5` (constant τ for clarity).
**Truth.** ATT = 5 by construction.
**Comparison.** Naive DiD (biased high — treated have higher x, hence steeper trend) vs. IPW with `\hat p(x)` logit weights vs. truth.
**Visualization.** Histogram of 1,000 Monte Carlo estimates for each estimator, vertical line at 5. Matches Scott's `selection.do` style — `simulate` block, summary, then density.

### L4-Sim: already present.

### L5-Sim: DR survives when *one* model is misspecified

**DGP.** Two covariates `x1, x2`. Truth: `p(x) = plogis(x1 + x2)`, `\mu_0(x) = x1 + x1^2 + x2`. ATT = 2 (constant for clarity). Run **two scenarios**:
- (A) Misspecify `\mu_0` (drop `x1^2`), keep `p(x)` correct.
- (B) Misspecify `p(x)` (drop `x2`), keep `\mu_0` correct.

**Truth.** ATT = 2, 5,000 reps.
**Comparison.** OR | IPW | DR. Two tables, one per scenario.
**Visualization.** Two side-by-side tables. In (A): OR biased, IPW clean, DR clean. In (B): OR clean, IPW biased, DR clean. The punchline is the **DR row sitting at 2 in both panels**.

### L6-Sim: CC hidden linearity, SYG-style toy

**DGP.** 50 "states" × 11 years. Each state has time-invariant `Z = south ∈ {0,1}` and pre-treatment level `X_baseline = poverty`. South states more likely treated. `y0_it = α_i + γ_t + 0.5*Z_i*t + 0.3*X_baseline_i*t + e` (region- and level-dependent trends). `y1 = y0` (true ATT = 0).
**Truth.** ATT = 0. Hidden linearity bias creates a positive sham effect.
**Comparison.** TWFE with `ΔX` only (positive bias, matches the +0.067 SYG headline) vs. AIPW with `(X_{t-1}, Z)` (≈ 0).
**Visualization.** Forest plot: four specs from L6-F7 table (TWFE-ΔX | RegAdj-ΔX+Z | RegAdj-Xprev+Z | RegAdj-all), with truth=0 vertical line. Mirrors the deck's existing SYG table but with the truth made manifest.

### L7-Sim: compositional drift in repeated cross-sections

**DGP.** Two rounds, 2,000 fresh households each. Pre-round: P(treat=1) = 0.5, x ~ N(0,1) in both arms. Post-round: P(treat=1) = 0.5, but **x|treat=1 ~ N(0.5,1)** (the treated *population* changed). `y0 = 2*x + t`, `y1 = y0 + 1` (constant τ=1 for the post-period treated).
**Truth.** ATT(post-period treated) = 1.
**Comparison.** Naive DiD (biased — picks up x-shift), DR-DiD (still biased because the conditional distribution of x|D=1 shifted), SX composition-corrected DR (clean).
**Visualization.** Three histograms of 1,000 sim estimates, vertical line at τ=1. Or a single table with Hausman p-values.

---

## 3. Critique of the existing PT-on-Y⁰ simulation (L2-F2j/k)

It is the **right shape**, but two style gaps relative to `na.do`:

1. **R, not Stata.** Every other Scott exemplar in `sims/` is `.do`. The deck mixes a single R block into a Stata-heavy course. Consider a `.do` companion in `glasgow/labs/sims/pt_in_y0.do` so the audience can paste it.
2. **The truth is computed but not *named*.** `na.do` always has `su delta_c if year>=1991 & group==1` — the truth printed beside the estimate. The current sim shows ΔY⁰_T − ΔY⁰_C ≈ 1.04 ≈ β·(ΔX^T − ΔX^C) = 1.0, which is the violation diagnostic, not the truth contrast. Add a regression of `y0` on `treat##post` to show DiD reads off ≈ 1 when truth is 0.

The DGP itself **is punchy** — 4 lines, β=2 hard-coded, ΔX^T=0.5 hard-coded. That's `na.do` discipline.

---

## 4. The Monte Carlo closer — restore it.

Yes. The Monte Carlo closer from CI-2 (lines 836-905, 4 DGPs × 10K sims × {TWFE, OR, IPW, DR}, with `mc_dr_1.png` and `mc_dr_2.png` already in `glasgow/decks/figures/`) is the **highest-leverage missing slide** in the deck. It is the only place where all four estimators are seen against the same truth in one frame. As a closing block, before the Lab slide:

1. **Frame 1: "Four DGPs, one truth, four estimators."** Bulleted: DGP1 both correct; DGP2 only OR correct; DGP3 only PS correct; DGP4 neither correct. N=1,000, 10K reps.
2. **Frame 2: DGP1 table** (line 838 — TWFE −20.95, OR ≈ 0, IPW ≈ 0, DR ≈ 0).
3. **Frame 3: `mc_dr_1.png`** — sampling distributions.
4. **Frame 4: DGP4 table** (line 873 — TWFE −16.4, OR −5.2, IPW −1.1, DR −3.2). The "neither model right" case.
5. **Frame 5: `mc_dr_2.png`.**
6. **Frame 6: synthesis** — "DR isn't magic. It's two chances, not infinity chances. When *both* are wrong, all four are biased — but DR has the lowest RMSE if either is even approximately right."

This block does what no other slide does: it shows the DGP4 punch — DR is *not* unbiased when both models are wrong. That keeps Scott honest (Estimation Philosophy rule 4: don't sell DR as a savior).

---

## 5. Top 5 simulation additions, ranked by leverage

1. **The Monte Carlo closer (Section 4 above).** Highest leverage — six slides, four estimators, four DGPs, two figures already migrated, code already exists in `covariates_monte_carlo.{do,R}`. Pure win.
2. **L5-Sim (DR either-model-correct).** Without this, the "doubly robust" punchline is taken on faith. Two scenarios, two tables, immense pedagogical payoff. Pairs with the closer.
3. **L6-Sim (CC hidden linearity toy).** The SYG numbers (+0.067 → +0.019) are persuasive but uncontrolled. A toy DGP with truth = 0 lets the audience *see* the bias and *see* AIPW kill it.
4. **L3-Sim (Abadie IPW).** Proof is dense; one DGP showing IPW beating naive DiD when selection-on-X is severe makes the algebra concrete.
5. **L2-Sim (OR alone).** Lowest of the five but still worth it — currently OR is taught entirely as a formula. A 1-slide DGP showing OR recover τ when TWFE-additive-X cannot would close the gap between "OR exists" and "OR works."

L7-Sim is **omitted from the top 5** deliberately: the compositional-shift DGP is harder to make punchy in one screen, and Hong's empirical figures already do the visceral work. If you have time, add it; otherwise the closer + L5 + L6 sims do the heavy lifting.
