## he_visualization.R
## ----------------------------------------------------------------------
## Two-panel visualization for the slide that explains
## why HC-robust SEs barely move the needle in DiD.
##
## Both panels share the SAME heteroskedasticity strength. What changes
## is the structure of the regressor:
##
##   Left  panel: continuous X, heteroskedastic errors (Var(e|X) ∝ X^2).
##                Vanilla SE is too narrow; HC1 matches the truth.
##   Right panel: binary balanced D, heteroskedasticity (treated have
##                larger variance than controls). Vanilla SE accidentally
##                matches the truth because of the balanced-binary
##                cancellation. HC1 matches too.
##
## Picture: histogram of beta-hat across 2000 sims = truth. Overlay two
## Normal curves: one with sd = mean(vanilla SE), one with sd = mean(HC1 SE).
##
## Output: ../../figures/he_vs_homo.pdf
## ----------------------------------------------------------------------

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(tidyr)
  library(sandwich)
})

source(file.path("..", "..", "..", "..", "_themes", "remix_theme.R"))

set.seed(20260511)
n_sim     <- 2000
n         <- 200
true_beta <- 1

## ---- Continuous X with heteroskedasticity ------------------------------
sim_cts <- replicate(n_sim, {
  x <- rnorm(n)
  e <- rnorm(n) * abs(x) * 2          # Var(e|x) = 4 x^2 -- strong fan shape
  y <- true_beta * x + e
  fit <- lm(y ~ x)
  c(coef(fit)["x"],
    sqrt(diag(vcov(fit)))["x"],
    sqrt(diag(vcovHC(fit, type = "HC1")))["x"])
})
res_cts <- as.data.frame(t(sim_cts))
colnames(res_cts) <- c("beta", "se_vanilla", "se_hc")

## ---- Binary balanced D with heteroskedasticity -------------------------
sim_bin <- replicate(n_sim, {
  D <- rep(c(0, 1), each = n/2)
  e <- rnorm(n) * (1 + D * 2)         # SD = 1 for controls, 3 for treated
  y <- true_beta * D + e
  fit <- lm(y ~ D)
  c(coef(fit)["D"],
    sqrt(diag(vcov(fit)))["D"],
    sqrt(diag(vcovHC(fit, type = "HC1")))["D"])
})
res_bin <- as.data.frame(t(sim_bin))
colnames(res_bin) <- c("beta", "se_vanilla", "se_hc")

## ---- Pretty print -------------------------------------------------------
cat("------- Continuous X, heteroskedastic -------\n")
cat(sprintf("Empirical sd of beta-hat:  %.3f\n",  sd(res_cts$beta)))
cat(sprintf("Mean vanilla SE:           %.3f\n",  mean(res_cts$se_vanilla)))
cat(sprintf("Mean HC1 SE:               %.3f\n\n", mean(res_cts$se_hc)))

cat("------- Binary balanced D, heteroskedastic -------\n")
cat(sprintf("Empirical sd of beta-hat:  %.3f\n",  sd(res_bin$beta)))
cat(sprintf("Mean vanilla SE:           %.3f\n",  mean(res_bin$se_vanilla)))
cat(sprintf("Mean HC1 SE:               %.3f\n\n", mean(res_bin$se_hc)))

## ---- Build long plot frame ---------------------------------------------
hist_df <- bind_rows(
  data.frame(panel = "Continuous X  (heteroskedasticity hurts vanilla)",
             beta = res_cts$beta),
  data.frame(panel = "Binary balanced D  (vanilla = HC: the DiD case)",
             beta = res_bin$beta)
)
hist_df$panel <- factor(hist_df$panel,
                        levels = c("Continuous X  (heteroskedasticity hurts vanilla)",
                                   "Binary balanced D  (vanilla = HC: the DiD case)"))

# Mean SEs per panel for the overlay curves
mean_se <- bind_rows(
  data.frame(panel = "Continuous X  (heteroskedasticity hurts vanilla)",
             sd_vanilla = mean(res_cts$se_vanilla),
             sd_hc      = mean(res_cts$se_hc),
             emp_sd     = sd(res_cts$beta)),
  data.frame(panel = "Binary balanced D  (vanilla = HC: the DiD case)",
             sd_vanilla = mean(res_bin$se_vanilla),
             sd_hc      = mean(res_bin$se_hc),
             emp_sd     = sd(res_bin$beta))
)
mean_se$panel <- factor(mean_se$panel,
                        levels = levels(hist_df$panel))

# Per-panel x-grid for the Normal curves
curve_df <- mean_se %>%
  rowwise() %>%
  do({
    panel_lvl <- .$panel
    sd_v <- .$sd_vanilla; sd_h <- .$sd_hc; emp <- .$emp_sd
    xs <- seq(true_beta - 4*emp, true_beta + 4*emp, length.out = 250)
    data.frame(
      panel   = panel_lvl,
      beta    = xs,
      Vanilla = dnorm(xs, mean = true_beta, sd = sd_v),
      HC1     = dnorm(xs, mean = true_beta, sd = sd_h)
    )
  }) %>%
  ungroup() %>%
  pivot_longer(c(Vanilla, HC1), names_to = "method", values_to = "density")
curve_df$method <- factor(curve_df$method, levels = c("Vanilla", "HC1"),
                          labels = c("Vanilla SE", "HC1 robust SE"))

## ---- Plot ---------------------------------------------------------------
p <- ggplot(hist_df, aes(x = beta)) +
  geom_histogram(aes(y = after_stat(density)),
                 bins = 45,
                 fill = remix_color("warmgray"), alpha = 0.45,
                 color = remix_color("cream"), linewidth = 0.1) +
  geom_vline(xintercept = true_beta,
             color = remix_color("charcoal"), linewidth = 0.45,
             linetype = "dashed") +
  geom_line(data = curve_df,
            aes(x = beta, y = density, color = method, linetype = method),
            linewidth = 1.0) +
  scale_color_manual(values = c("Vanilla SE"    = remix_color("remixgreen"),
                                "HC1 robust SE" = remix_color("forest")),
                     name = NULL) +
  scale_linetype_manual(values = c("Vanilla SE"    = "longdash",
                                   "HC1 robust SE" = "solid"),
                        name = NULL) +
  facet_wrap(~ panel, ncol = 2, scales = "free") +
  labs(
    title    = "When does HC matter? Compare each SE formula to the truth.",
    subtitle = "Gray bars: empirical sampling distribution across 2000 simulations. Curves: what each SE formula thinks the spread is.",
    x        = expression(hat(beta)),
    y        = "density",
    caption  = "Continuous X (left): vanilla curve is far too narrow -- vanilla SE underestimates the truth. HC1 matches. \n Binary balanced D (right): same heteroskedasticity, but vanilla and HC1 BOTH track the histogram. The het correction adds nothing."
  ) +
  theme_remix() +
  theme(legend.position = "bottom",
        strip.text = element_text(face = "bold", size = 10),
        panel.spacing.x = unit(1.2, "lines"))

remix_save("../../figures/he_vs_homo.pdf", p, width = 10.0, height = 5.4)
cat("Saved: ../../figures/he_vs_homo.pdf\n")
