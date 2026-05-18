## ci_forest_plot.R
## ----------------------------------------------------------------------
## Three-panel CI forest plot that visualizes Type I error rates:
##
##   Panel 1 — Non-clustered data, vanilla OLS SE       → ~5% miss
##   Panel 2 — Clustered data,    vanilla OLS SE        → ~30% miss
##   Panel 3 — Clustered data,    cluster-robust SE     → ~5% miss
##
## True beta = 0 by construction. We draw 100 random CIs and color them
## "Hit" (caught the true beta) or "Missed" (didn't). Visually, panel 2
## is a wall of red — clustering breaks vanilla. Panel 3 fixes it.
##
## Pattern adapted from Yuki Yanai's simulation, reused in
## Cunningham, _Causal Inference: The Mixtape_, Section 2.27.
##
## Output: ../../figures/cluster_ci_forest.pdf
## ----------------------------------------------------------------------

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(mvtnorm)
  library(sandwich)
  library(lmtest)
})

source(file.path("..", "..", "..", "..", "_themes", "remix_theme.R"))

set.seed(20260511)

## ---- Yanai-style clustered DGP ----------------------------------------
gen_cluster <- function(param = c(0.4, 0), n = 1000, n_cluster = 50, rho = 0.5) {
  ## Individual level
  Sigma_i  <- matrix(c(1, 0, 0, 1 - rho), ncol = 2)
  values_i <- rmvnorm(n = n, sigma = Sigma_i)
  ## Cluster level
  cluster_name <- rep(1:n_cluster, each = n / n_cluster)
  Sigma_cl  <- matrix(c(1, 0, 0, rho), ncol = 2)
  values_cl <- rmvnorm(n = n_cluster, sigma = Sigma_cl)
  ## Predictor and error each have an individual + cluster component
  x     <- values_i[, 1] + rep(values_cl[, 1], each = n / n_cluster)
  error <- values_i[, 2] + rep(values_cl[, 2], each = n / n_cluster)
  y     <- param[1] + param[2] * x + error
  data.frame(x, y, cluster = cluster_name)
}

## ---- single simulation: returns b1, SE, CI ----------------------------
cluster_sim <- function(param = c(0.4, 0), n = 1000, n_cluster = 50,
                        rho = 0.5, cluster_robust = FALSE) {
  df  <- gen_cluster(param = param, n = n, n_cluster = n_cluster, rho = rho)
  fit <- lm(y ~ x, data = df)
  b1  <- coef(fit)[2]
  if (!cluster_robust) {
    se <- sqrt(diag(vcov(fit)))[2]
  } else {
    se <- sqrt(diag(vcovCL(fit, cluster = ~cluster, type = "HC1")))[2]
  }
  tc    <- qt(0.025, df = n - 2, lower.tail = FALSE)
  lower <- b1 - tc * se
  upper <- b1 + tc * se
  c(b1 = unname(b1), se = unname(se), lower = unname(lower), upper = unname(upper))
}

run_cluster_sim <- function(n_sims, param, n, n_cluster, rho, cluster_robust) {
  out <- replicate(n_sims, cluster_sim(param, n, n_cluster, rho, cluster_robust))
  out <- as.data.frame(t(out))
  names(out) <- c("b1", "se", "ci_lo", "ci_hi")
  out$id <- seq_len(nrow(out))
  out$caught <- (out$ci_lo <= param[2]) & (out$ci_hi >= param[2])
  out
}

## ---- Three scenarios --------------------------------------------------
n_sims <- 2000
param  <- c(0.4, 0)

cat("Running scenario 1: no clustering, vanilla SE...\n")
sc1 <- run_cluster_sim(n_sims, param, n=1000, n_cluster=50, rho=0,    cluster_robust=FALSE)
cat("Running scenario 2: clustering present, vanilla SE...\n")
sc2 <- run_cluster_sim(n_sims, param, n=1000, n_cluster=50, rho=0.5, cluster_robust=FALSE)
cat("Running scenario 3: clustering present, cluster-robust SE...\n")
sc3 <- run_cluster_sim(n_sims, param, n=1000, n_cluster=50, rho=0.5, cluster_robust=TRUE)

t1_1 <- 1 - mean(sc1$caught)
t1_2 <- 1 - mean(sc2$caught)
t1_3 <- 1 - mean(sc3$caught)

cat(sprintf("\nType I error rates (target = 5%%):\n"))
cat(sprintf("  Scenario 1 (no clustering, vanilla):     %.1f%%\n", 100 * t1_1))
cat(sprintf("  Scenario 2 (clustering, vanilla):        %.1f%%\n", 100 * t1_2))
cat(sprintf("  Scenario 3 (clustering, cluster-robust): %.1f%%\n", 100 * t1_3))

## ---- Sample 100 CIs per scenario for the forest plot -----------------
sample_ci <- function(sim, label, type1_rate) {
  s <- slice_sample(sim, n = 100)
  s$panel  <- sprintf("%s\n(Type I error = %.1f%%)", label, 100 * type1_rate)
  s$order  <- rank(s$b1, ties.method = "first")
  s
}

forest_df <- bind_rows(
  sample_ci(sc1, "No clustering · vanilla SE",         t1_1),
  sample_ci(sc2, "Clustering · vanilla SE",            t1_2),
  sample_ci(sc3, "Clustering · cluster-robust SE",     t1_3)
)
forest_df$panel <- factor(forest_df$panel,
  levels = c(
    sprintf("No clustering · vanilla SE\n(Type I error = %.1f%%)",          100 * t1_1),
    sprintf("Clustering · vanilla SE\n(Type I error = %.1f%%)",             100 * t1_2),
    sprintf("Clustering · cluster-robust SE\n(Type I error = %.1f%%)",      100 * t1_3)
  )
)
forest_df$caught_lbl <- factor(ifelse(forest_df$caught, "Hit (caught true beta)", "Missed"),
                               levels = c("Missed", "Hit (caught true beta)"))

## ---- Plot --------------------------------------------------------------
p <- ggplot(forest_df, aes(x = order, y = b1, ymin = ci_lo, ymax = ci_hi,
                           color = caught_lbl, alpha = caught_lbl)) +
  geom_hline(yintercept = 0, color = remix_color("charcoal"),
             linewidth = 0.5, linetype = "dashed") +
  geom_pointrange(size = 0.25, linewidth = 0.45) +
  coord_flip(ylim = c(-0.25, 0.25)) +
  scale_color_manual(values = c("Missed"             = remix_color("alertred"),
                                "Hit (caught true beta)" = remix_color("forest")),
                     name = NULL) +
  scale_alpha_manual(values = c("Missed" = 0.95, "Hit (caught true beta)" = 0.30),
                     guide = "none") +
  facet_wrap(~ panel, ncol = 3) +
  labs(
    title    = "Coverage of 95% CIs across three scenarios",
    subtitle = "True beta = 0. Each line = one simulation's 95% CI. Red = missed truth. Green = caught it.",
    x        = NULL,
    y        = expression(hat(beta)[1]),
    caption  = "Sampled 100 of 2000 simulations per panel. Type I error rate displayed in each panel header. Pattern adapted from Yanai (via Cunningham, Mixtape §2.27)."
  ) +
  theme_remix() +
  theme(
    axis.text.y     = element_blank(),
    axis.ticks.y    = element_blank(),
    strip.text      = element_text(face = "bold", size = 9.5, lineheight = 1.1),
    legend.position = "bottom",
    panel.spacing.x = unit(1.0, "lines")
  )

remix_save("../../figures/cluster_ci_forest.pdf", p, width = 11.0, height = 5.4)
cat("\nSaved: ../../figures/cluster_ci_forest.pdf\n")
