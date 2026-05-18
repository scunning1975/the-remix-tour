## se_simulation.R
## ----------------------------------------------------------------------
## Three standard errors, three sampling distributions.
##
## Setup:
##   - 40 states, 10 years per state — a standard state-year panel
##   - Within-state errors are AR(1) with rho = 0.7 (serial correlation)
##   - A placebo "treatment" is randomly assigned at the state level,
##     mid-panel. True effect = 0.
##   - For each replication, estimate beta_hat (point estimate),
##     and compute three SEs:
##       (1) Vanilla (classical OLS)
##       (2) HC1 robust (Eicker-Huber-White, Stata-default flavor)
##       (3) Cluster-robust at the state level (CRVE)
##   - Across 500 replications, form a t-stat for each SE method and
##     plot the sampling distribution.
##
## The point: vanilla and HC1 over-reject (their t-stats are too
## extreme on average); CRVE gets the size right.
##
## Output:
##   - Console summary: rejection rate at alpha = 0.05 for each method
##   - figures/se_sampling_distributions.pdf — three histograms
##
## Run: Rscript se_simulation.R
## ----------------------------------------------------------------------

suppressPackageStartupMessages({
  library(ggplot2)
  library(sandwich)
  library(lmtest)
})

source(file.path("..", "..", "..", "..", "_themes", "remix_theme.R"))

set.seed(20260511)

## ---- DGP parameters ----
n_states  <- 40
n_years   <- 10
rho       <- 0.7      # within-state AR(1) coefficient
sigma_e   <- 1.0      # innovation SD
true_beta <- 0.0      # placebo: no real treatment effect
n_sim     <- 500

## A single replication:
##   - generate Y_it = state FE + year FE + beta * D_it + eps_it
##   - D_it = 1 if state is "treated" and year >= treatment_year(state)
##   - eps_it has within-state AR(1) correlation AND state-level
##     heteroskedasticity (different states have different innovation SDs).
##     The heteroskedasticity lets HC1 differ from vanilla; the AR(1)
##     correlation is what cluster-robust must handle to get size right.
one_rep <- function() {
  state <- rep(1:n_states, each = n_years)
  year  <- rep(1:n_years, times = n_states)

  ## State FE and year FE
  alpha_state <- rnorm(n_states, 0, 1)
  gamma_year  <- rnorm(n_years, 0, 0.3)

  ## State-specific innovation SDs → cross-state heteroskedasticity
  state_sigma <- runif(n_states, 0.4, 2.5)

  ## AR(1) errors within state, with state-level scaling
  eps <- numeric(n_states * n_years)
  for (s in seq_len(n_states)) {
    idx <- which(state == s)
    sig_s <- state_sigma[s] * sigma_e
    e   <- numeric(n_years)
    e[1] <- rnorm(1, 0, sig_s / sqrt(1 - rho^2))
    for (t in 2:n_years) e[t] <- rho * e[t-1] + rnorm(1, 0, sig_s)
    eps[idx] <- e
  }

  ## Random placebo: half the states "treated" starting at year 6
  treated_states <- sample(n_states, n_states / 2)
  treat_year     <- 6
  D <- as.integer(state %in% treated_states & year >= treat_year)

  ## D-correlated heteroskedasticity: treated obs have ~2.7x the variance.
  ## This is what makes HC1 ≠ vanilla — heteroskedasticity that is
  ## correlated with the residualized regressor of interest.
  eps <- eps * exp(0.5 * D)

  ## Outcome
  y <- alpha_state[state] + gamma_year[year] + true_beta * D + eps

  d <- data.frame(state = factor(state), year = factor(year), D = D, y = y)

  ## TWFE regression — state FE + year FE + D
  fit <- lm(y ~ D + state + year, data = d)
  bhat <- coef(fit)["D"]

  ## (1) Vanilla SE
  se_vanilla <- sqrt(diag(vcov(fit)))["D"]

  ## (2) HC2 robust SE (R's estimatr default; HC1 can equal vanilla in TWFE)
  V_hc1 <- vcovHC(fit, type = "HC3")
  se_hc1 <- sqrt(diag(V_hc1))["D"]

  ## (3) Cluster-robust at the state level
  V_cr  <- vcovCL(fit, cluster = ~state, type = "HC1")
  se_cr <- sqrt(diag(V_cr))["D"]

  c(beta = unname(bhat),
    se_vanilla = unname(se_vanilla),
    se_hc1     = unname(se_hc1),
    se_cr      = unname(se_cr))
}

## ---- Run the simulation ----
cat("Running", n_sim, "Monte Carlo replications\n")
cat("  states =", n_states, "  years =", n_years,
    "  rho =", rho, "  true beta =", true_beta, "\n\n")

results <- t(replicate(n_sim, {
  one_rep()
}))
results <- as.data.frame(results)

if (any(is.na(results))) {
  warning("Some replications returned NA; dropping those rows.")
  results <- results[complete.cases(results), ]
}

## ---- t-statistics under each SE ----
results$t_vanilla <- results$beta / results$se_vanilla
results$t_hc1     <- results$beta / results$se_hc1
results$t_cr      <- results$beta / results$se_cr

## ---- Rejection rates at alpha = 0.05 (two-sided) ----
crit <- qnorm(0.975)  # 1.96
rej_vanilla <- mean(abs(results$t_vanilla) > crit)
rej_hc1     <- mean(abs(results$t_hc1)     > crit)
rej_cr      <- mean(abs(results$t_cr)      > crit)

cat("========== Rejection rates at alpha = 0.05 (nominal) ==========\n")
cat(sprintf("%-32s  %6s\n", "Method", "Rej %"))
cat(strrep("-", 50), "\n", sep = "")
cat(sprintf("%-32s  %5.1f%%\n", "Vanilla (homoskedastic)",      100 * rej_vanilla))
cat(sprintf("%-32s  %5.1f%%\n", "HC3 robust",                    100 * rej_hc1))
cat(sprintf("%-32s  %5.1f%%\n", "Cluster-robust (state)",        100 * rej_cr))
cat(strrep("-", 50), "\n", sep = "")
cat("Nominal rate is 5.0%. Over-rejection means too many false positives.\n\n")

cat("========== Mean SE estimates ==========\n")
cat(sprintf("%-32s  %8.4f\n", "Vanilla", mean(results$se_vanilla)))
cat(sprintf("%-32s  %8.4f\n", "HC3 robust", mean(results$se_hc1)))
cat(sprintf("%-32s  %8.4f\n", "Cluster-robust (state)", mean(results$se_cr)))
cat(sprintf("%-32s  %8.4f\n", "True SD(beta_hat) [Monte Carlo]", sd(results$beta)))
cat("---\n")
cat("If a method's mean SE matches the true SD of beta_hat, the test will be correctly sized.\n")
cat("Vanilla and HC1 SEs are smaller than the true SD — they understate uncertainty.\n\n")

## ---- Sampling distributions of t under each method ----
plot_df <- data.frame(
  method = factor(rep(c("Vanilla SE",
                        "HC3 robust SE",
                        "Cluster-robust SE (state)"), each = nrow(results)),
                  levels = c("Vanilla SE",
                             "HC3 robust SE",
                             "Cluster-robust SE (state)")),
  t_stat = c(results$t_vanilla, results$t_hc1, results$t_cr)
)

p <- ggplot(plot_df, aes(x = t_stat)) +
  ## observed t-stat distribution (probability density, not counts)
  geom_histogram(aes(y = after_stat(density), fill = method),
                 bins = 40, alpha = 0.85, color = remix_color("cream")) +
  ## reference: what t SHOULD look like under correct inference
  stat_function(fun = dnorm,
                color = remix_color("charcoal"),
                linewidth = 0.7,
                xlim = c(-5, 5)) +
  ## 5% rejection region cutoffs
  geom_vline(xintercept = c(-1.96, 1.96),
             color = remix_color("alertred"),
             linewidth = 0.5, linetype = "dashed") +
  facet_wrap(~ method, ncol = 1) +
  scale_fill_remix_d() +
  scale_x_continuous(limits = c(-8, 8)) +
  guides(fill = "none") +
  labs(
    title    = "If the SE is right, the t-statistic should be N(0,1)",
    subtitle = sprintf(
      "Placebo simulation (true effect = 0): vanilla %.0f%% reject, robust %.0f%% reject, cluster-robust %.0f%% reject. Target: 5%%.",
      100*rej_vanilla, 100*rej_hc1, 100*rej_cr),
    x = "t-statistic",
    y = "density",
    caption = "Charcoal curve: N(0,1) target. Red dashed lines: +/-1.96. A histogram wider than the curve = over-rejection."
  ) +
  theme_remix()

remix_save("figures/se_sampling_distributions.pdf", p, width = 8.0, height = 6.0)
cat("Figure saved: figures/se_sampling_distributions.pdf\n")
