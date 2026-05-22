# %%
library(tidyverse)
library(kfbmisc)

set.seed(123)

# %%
n <- 300
df <- tibble(
  id = 1:n,
  dose = runif(n, 0, 20)
) |>
  mutate(
    dose = round(dose / 10) * 10,
    delta_y = 0 + 0.2 * dose + rnorm(n(), sd = 5)
  ) |>
  mutate(
    dose_label = factor(
      dose,
      levels = c(0, 10, 20),
      labels = c("0 mg", "10 mg", "20 mg")
    )
  )

means <- df |>
  summarise(.by = c(dose, dose_label), mean_delta = mean(delta_y))

# %%
(p_raw_first_differences <- ggplot() +
  geom_point(
    aes(x = dose, y = delta_y, color = "Observed Data"),
    data = df,
    alpha = 0.8,
    size = 2,
    shape = "circle"
  ) +
  geom_point(
    aes(x = dose, y = mean_delta, color = dose_label),
    data = means,
    shape = 18,
    size = 4
  ) +
  scale_color_manual(
    values = c(
      "0 mg" = "black",
      "10 mg" = kfbmisc::kyle_color("green"),
      "20 mg" = kfbmisc::kyle_color("blue"),
      "Observed Data" = kfbmisc::tailwind_color("zinc-300")
    ),
    name = NULL,
    labels = c(
      "0mg group avg.",
      "10mg group avg.",
      "20mg group avg.",
      "Observed Data"
    )
  ) +
  labs(
    x = "$\\mathrm{Dose},\\ D_i$",
    y = "$\\Delta y_i = y_{i,1} - y_{i,0}$"
  ) +
  scale_x_continuous(limits = c(0, 24)) +
  kfbmisc::theme_kyle(legend = "top"))

## p_implied_counterfactual
count_trend_estimate <- with(means, mean_delta[dose == 0])
(p_implied_counterfactual <- ggplot() +
  geom_point(
    aes(x = dose, y = delta_y, color = "Observed Data"),
    data = df,
    alpha = 0.8,
    size = 2,
    shape = "circle"
  ) +
  geom_point(
    aes(x = dose, y = mean_delta, color = dose_label),
    data = means,
    shape = 18,
    size = 4
  ) +
  ## Count trend
  geom_hline(
    yintercept = count_trend_estimate,
    linewidth = 1.5,
    linetype = "dashed",
    color = kfbmisc::tailwind_color("zinc-600")
  ) +
  annotate(
    "label",
    label = "$\\widehat{\\Delta y_i(0)}$",
    x = 22,
    y = count_trend_estimate - 1,
    size = 5,
    text.colour = tailwind_color("zinc-800"),
    linewidth = 0,
    label.r = unit(0, "pt"),
    label.padding = unit(6, "pt"),
    hjust = 0,
    vjust = 1
  ) +
  scale_color_manual(
    values = c(
      "0 mg" = "black",
      "10 mg" = kfbmisc::kyle_color("green"),
      "20 mg" = kfbmisc::kyle_color("blue"),
      "Observed Data" = kfbmisc::tailwind_color("zinc-300")
    ),
    name = NULL,
    labels = c(
      "0mg group avg.",
      "10mg group avg.",
      "20mg group avg.",
      "Observed Data"
    )
  ) +
  labs(
    x = "$\\mathrm{Dose},\\ D_i$",
    y = "$\\Delta y_i = y_{i,1} - y_{i,0}$"
  ) +
  scale_x_continuous(limits = c(0, 24)) +
  kfbmisc::theme_kyle(legend = "top"))

## p_did_estimates
(p_did_estimates <- ggplot() +
  geom_point(
    aes(x = dose, y = delta_y, color = "Observed Data"),
    data = df,
    alpha = 0.8,
    size = 2,
    shape = "circle"
  ) +
  geom_point(
    aes(x = dose, y = mean_delta, color = dose_label),
    data = means,
    shape = 18,
    size = 4
  ) +
  ## Count trend
  geom_hline(
    yintercept = count_trend_estimate,
    linewidth = 1.5,
    linetype = "dashed",
    color = kfbmisc::tailwind_color("zinc-600")
  ) +
  annotate(
    "label",
    label = "$\\widehat{\\Delta y_i(0)}$",
    x = 22,
    y = count_trend_estimate - 1,
    size = 5,
    text.colour = tailwind_color("zinc-800"),
    linewidth = 0,
    label.r = unit(0, "pt"),
    label.padding = unit(6, "pt"),
    hjust = 0,
    vjust = 1
  ) +
  ## TE estimate for 10mg
  annotate(
    "line",
    x = c(10, 10),
    y = c(count_trend_estimate, with(means, mean_delta[dose == 10])),
    linewidth = 1.5,
    color = kfbmisc::kyle_color("green")
  ) +
  annotate(
    "label",
    label = "$= \\hat{\\tau}_{10}$",
    x = 10 + 0.5,
    # fmt: skip
    y = 1 / 2 * with(means, mean_delta[dose == 10]) -
      1 / 2 * count_trend_estimate,
    size = 5,
    text.colour = tailwind_color("zinc-800"),
    fill = NA,
    linewidth = 0,
    label.r = unit(0, "pt"),
    # label.padding = unit(6, "pt"),
    hjust = 0,
    vjust = 0.5
  ) +
  ## TE estimate for 20mg
  annotate(
    "line",
    x = c(20, 20),
    y = c(count_trend_estimate, with(means, mean_delta[dose == 20])),
    linewidth = 1.5,
    color = kfbmisc::kyle_color("blue")
  ) +
  annotate(
    "label",
    label = "$= \\hat{\\tau}_{20}$",
    x = 20 + 0.5,
    # fmt: skip
    y = 1 / 2 * with(means, mean_delta[dose == 20]) -
      1 / 2 * count_trend_estimate,
    size = 5,
    text.colour = tailwind_color("zinc-800"),
    fill = NA,
    linewidth = 0,
    label.r = unit(0, "pt"),
    # label.padding = unit(6, "pt"),
    hjust = 0,
    vjust = 0.5
  ) +
  scale_color_manual(
    values = c(
      "0 mg" = "black",
      "10 mg" = kfbmisc::kyle_color("green"),
      "20 mg" = kfbmisc::kyle_color("blue"),
      "Observed Data" = kfbmisc::tailwind_color("zinc-300")
    ),
    name = NULL,
    labels = c(
      "0mg group avg.",
      "10mg group avg.",
      "20mg group avg.",
      "Observed Data"
    )
  ) +
  labs(
    x = "$\\mathrm{Dose},\\ D_i$",
    y = "$\\Delta y_i = y_{i,1} - y_{i,0}$"
  ) +
  scale_x_continuous(limits = c(0, 24)) +
  kfbmisc::theme_kyle(legend = "top"))

# %%
## Export figures
tikzsave(
  here::here("figures/recreate/discrete_raw_first_differences.pdf"),
  plot = p_raw_first_differences,
  width = 8,
  height = 5
)
tikzsave(
  here::here("figures/recreate/discrete_implied_counterfactual.pdf"),
  plot = p_implied_counterfactual,
  width = 8,
  height = 5
)
tikzsave(
  here::here("figures/recreate/discrete_did_estimates.pdf"),
  plot = p_did_estimates,
  width = 8,
  height = 5
)
