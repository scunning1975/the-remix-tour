##############################################################################
# regenerate_mc_figures.R
# author: Scott Cunningham (Baylor)
# description: Re-render the 4-DGP Monte Carlo summary figures in the remix
#              aesthetic. Uses the published bias/SE/coverage numbers from
#              Sant'Anna-Zhao (2020); does NOT re-run the 10K MC simulations.
##############################################################################

# Load the remix theme so the figures match the rest of the deck
source(file.path("..", "..", "_themes", "remix_theme.R"))

library(ggplot2)
library(dplyr)

##############################################################################
# The data: Sant'Anna-Zhao Monte Carlo, summary across 10,000 replications
# Sample size n = 1,000 per replication. True ATT = 0 in all DGPs.
# DGP1: Both OR and propensity score correct
# DGP4: Neither OR nor propensity score correct
##############################################################################

# DGP1: both correct
twfe_bias_1     <- -20.95
or_bias_1       <-  -0.001
ipw_bias_1      <-   0.026
dr_bias_1       <-  -0.001

twfe_se_1       <-   2.53
or_se_1         <-   0.10
ipw_se_1        <-   2.66
dr_se_1         <-   0.11

twfe_coverage_1 <-   0.000
or_coverage_1   <-   0.950
ipw_coverage_1  <-   0.952
dr_coverage_1   <-   0.947

# DGP4: both wrong
twfe_bias_4     <- -16.38
or_bias_4       <-  -5.20
ipw_bias_4      <-  -1.08
dr_bias_4       <-  -3.19

twfe_se_4       <-   3.63
or_se_4         <-   1.29
ipw_se_4        <-   2.37
dr_se_4         <-   1.29

twfe_coverage_4 <-   0.000
or_coverage_4   <-   0.015
ipw_coverage_4  <-   0.949
dr_coverage_4   <-   0.308

##############################################################################
# Build a tidy data frame for each DGP
##############################################################################

dgp1 <- data.frame(
  estimator = c("TWFE", "OR", "IPW", "DR"),
  bias      = c(twfe_bias_1, or_bias_1, ipw_bias_1, dr_bias_1),
  se        = c(twfe_se_1,   or_se_1,   ipw_se_1,   dr_se_1),
  coverage  = c(twfe_coverage_1, or_coverage_1, ipw_coverage_1, dr_coverage_1)
)
dgp1$lo <- dgp1$bias - 1.96 * dgp1$se
dgp1$hi <- dgp1$bias + 1.96 * dgp1$se
dgp1$estimator <- factor(dgp1$estimator, levels = c("TWFE", "OR", "IPW", "DR"))

dgp4 <- data.frame(
  estimator = c("TWFE", "OR", "IPW", "DR"),
  bias      = c(twfe_bias_4, or_bias_4, ipw_bias_4, dr_bias_4),
  se        = c(twfe_se_4,   or_se_4,   ipw_se_4,   dr_se_4),
  coverage  = c(twfe_coverage_4, or_coverage_4, ipw_coverage_4, dr_coverage_4)
)
dgp4$lo <- dgp4$bias - 1.96 * dgp4$se
dgp4$hi <- dgp4$bias + 1.96 * dgp4$se
dgp4$estimator <- factor(dgp4$estimator, levels = c("TWFE", "OR", "IPW", "DR"))

##############################################################################
# Figure 1 — DGP1: both models correct
# Forest plot of bias ± 1.96·SE, truth at 0
##############################################################################

p1 <- ggplot(dgp1, aes(x = bias, y = estimator)) +
  geom_vline(xintercept = 0, color = remix_color("warmgray"),
             linewidth = 0.4, linetype = "dashed") +
  geom_errorbarh(aes(xmin = lo, xmax = hi),
                 height = 0.25, color = remix_color("ocean"), linewidth = 1.2) +
  geom_point(size = 4.2, color = remix_color("forest")) +
  geom_text(aes(label = sprintf("bias = %.2f\ncov = %.0f%%", bias, 100*coverage)),
            hjust = -0.15, vjust = 0.5, size = 3.2,
            color = remix_color("charcoal")) +
  scale_x_continuous(limits = c(-26, 8), breaks = c(-25, -20, -15, -10, -5, 0, 5)) +
  labs(x = "Bias (true ATT = 0)", y = NULL,
       title = NULL,
       subtitle = NULL,
       caption = "Bias ± 1.96·SE across 10,000 Monte Carlo replications, n = 1,000.") +
  theme_remix(base_size = 12) +
  theme(plot.caption = element_text(size = 9))

remix_save("../../zurich/decks/figures/mc_dr_1.pdf", p1,
           width = 7.0, height = 4.0)
cat("Saved: zurich/decks/figures/mc_dr_1.pdf\n")

##############################################################################
# Figure 2 — DGP4: both models wrong
# Same forest plot; DR now misses the truth, IPW survives
##############################################################################

p4 <- ggplot(dgp4, aes(x = bias, y = estimator)) +
  geom_vline(xintercept = 0, color = remix_color("warmgray"),
             linewidth = 0.4, linetype = "dashed") +
  geom_errorbarh(aes(xmin = lo, xmax = hi),
                 height = 0.25, color = remix_color("ocean"), linewidth = 1.2) +
  geom_point(size = 4.2, color = remix_color("forest")) +
  geom_text(aes(label = sprintf("bias = %.2f\ncov = %.0f%%", bias, 100*coverage)),
            hjust = -0.15, vjust = 0.5, size = 3.2,
            color = remix_color("charcoal")) +
  scale_x_continuous(limits = c(-22, 8), breaks = c(-20, -15, -10, -5, 0, 5)) +
  labs(x = "Bias (true ATT = 0)", y = NULL,
       title = NULL,
       subtitle = NULL,
       caption = "Bias ± 1.96·SE across 10,000 Monte Carlo replications, n = 1,000.") +
  theme_remix(base_size = 12) +
  theme(plot.caption = element_text(size = 9))

remix_save("../../zurich/decks/figures/mc_dr_2.pdf", p4,
           width = 7.0, height = 4.0)
cat("Saved: zurich/decks/figures/mc_dr_2.pdf\n")
