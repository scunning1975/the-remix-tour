################################################################################
# name: equivalence.R
# author: scott cunningham
# description: five ways to compute the same 2x2 DiD
#   1. Manual cell means
#   2. OLS with interactions (post x treat)
#   3. TWFE (unit + time fixed effects)
#   4. Long-difference regression (horizontal: Delta Y on D)
#   5. Group-difference regression (vertical: gap on Post)
################################################################################

library(tidyverse)
library(fixest)
library(haven)

# Load and clean data --------------------------------------------------------

data <- haven::read_dta("https://github.com/scunning1975/mixtape/raw/master/castle.dta")

data <- data %>%
  filter(!(effyear %in% c(2005, 2007, 2008, 2009))) %>%
  mutate(
    year  = as.numeric(year),
    post  = ifelse(year >= 2006, 1, 0),
    treat = ifelse(effyear == 2006, 1, 0)
  ) %>%
  filter(year %in% c(2005, 2006))

# 1. Manual 2x2 --------------------------------------------------------------

means <- data %>%
  group_by(treat, post) %>%
  summarise(y = mean(l_homicide, na.rm = TRUE), .groups = "drop")

y11 <- means$y[means$treat == 1 & means$post == 1]
y10 <- means$y[means$treat == 1 & means$post == 0]
y01 <- means$y[means$treat == 0 & means$post == 1]
y00 <- means$y[means$treat == 0 & means$post == 0]

# Way 1: first-difference arithmetic (subtract across time, then across groups)
did_fd <- (y11 - y10) - (y01 - y00)
cat("Way 1 first-difference arithmetic:", round(did_fd, 6), "\n")

# Way 2: group-difference arithmetic (subtract across groups, then across time)
did_gd <- (y11 - y01) - (y10 - y00)
cat("Way 2 group-difference arithmetic:", round(did_gd, 6), "\n")

# 2. OLS with interaction (post x treat) -------------------------------------

ols <- feols(l_homicide ~ post + treat + post:treat, data = data, cluster = ~sid)
cat("OLS interaction coef:", round(coef(ols)["post:treat"], 6), "\n")

# 3. TWFE (unit + year fixed effects) ----------------------------------------

twfe <- feols(l_homicide ~ post:treat | sid + year, data = data, cluster = ~sid)
cat("TWFE coef:", round(coef(twfe)["post:treat"], 6), "\n")

# 4. Long-difference regression (horizontal regression) ----------------------
#    Δy_i = alpha + beta * D_i + u_i
#    Subtract across time within each unit, then regress on treatment indicator.

long_diff <- data %>%
  select(sid, year, l_homicide, treat) %>%
  pivot_wider(names_from = year, values_from = l_homicide,
              names_prefix = "y") %>%
  mutate(delta_y = y2006 - y2005)

ld_reg <- feols(delta_y ~ treat, data = long_diff, cluster = ~sid)
cat("Long-difference (horizontal) coef:", round(coef(ld_reg)["treat"], 6), "\n")

# 5. Group-difference regression (vertical regression) -----------------------
#    gap_t = alpha + beta * Post_t + v_t
#    Subtract across groups within each period, then regress on post indicator.

group_diff <- data %>%
  group_by(treat, post) %>%
  summarise(y = mean(l_homicide, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = treat, values_from = y, names_prefix = "treat") %>%
  mutate(gap = treat1 - treat0)   # NJ - PA analog: treated minus control

gd_reg <- lm(gap ~ post, data = group_diff)
cat("Group-difference (vertical) coef:", round(coef(gd_reg)["post"], 6), "\n")

# Summary --------------------------------------------------------------------

cat("\n--- All six should be identical ---\n")
cat(sprintf("  1. First-diff arithmetic:    %.6f\n", did_fd))
cat(sprintf("  2. Group-diff arithmetic:    %.6f\n", did_gd))
cat(sprintf("  3. OLS interaction:          %.6f\n", coef(ols)["post:treat"]))
cat(sprintf("  4. TWFE:                     %.6f\n", coef(twfe)["post:treat"]))
cat(sprintf("  5. Long-difference (horiz):  %.6f\n", coef(ld_reg)["treat"]))
cat(sprintf("  6. Group-difference (vert):  %.6f\n", coef(gd_reg)["post"]))
