################################################################################
# name:        equivalence.R
# author:      scott cunningham
# description: Five equivalent paths to the 2x2 DiD on castle.dta.
#              Manual 2x2, OLS with interactions, TWFE, first-difference on
#              treatment dummy, and across-group difference on post dummy.
#              All five return the same DiD coefficient.
################################################################################

# install.packages(c("tidyverse", "fixest", "haven"))
library(tidyverse)
library(fixest)
library(haven)

# Load and filter the castle data: keep states adopting in 2006 + never-treated
data <- haven::read_dta(
  "https://github.com/scunning1975/mixtape/raw/master/castle.dta"
) %>%
  filter(!(effyear %in% c(2005, 2007, 2008, 2009))) %>%
  mutate(
    year  = as.numeric(year),
    post  = ifelse(year >= 2006, 1, 0),
    treat = ifelse(!is.na(effyear), 1, 0)
  ) %>%
  filter(year %in% c(2005, 2006))


# ----------------------------------------------------------------------------
# PATH 1: Manual 2x2 (Snow's "long differences": four averages, three subs)
# ----------------------------------------------------------------------------
cells <- data %>%
  group_by(treat, post) %>%
  summarise(y = mean(l_homicide, na.rm = TRUE), .groups = "drop")
print(cells)

did_manual <- with(cells, {
  (y[treat == 1 & post == 1] - y[treat == 1 & post == 0]) -
  (y[treat == 0 & post == 1] - y[treat == 0 & post == 0])
})
cat("Path 1 (Manual 2x2):", did_manual, "\n")


# ----------------------------------------------------------------------------
# PATH 2: OLS with treat x post interaction ("saturated" spec)
# ----------------------------------------------------------------------------
path2 <- feols(
  l_homicide ~ post + treat + post:treat,
  data = data, cluster = ~ sid
)
print(path2)


# ----------------------------------------------------------------------------
# PATH 3: TWFE — state and year fixed effects, DD on treat:post
# ----------------------------------------------------------------------------
path3 <- feols(
  l_homicide ~ treat:post | sid + year,
  data = data, cluster = ~ sid
)
print(path3)


# ----------------------------------------------------------------------------
# PATH 4: First-difference within unit (Delta Y_i) regressed on treatment dummy
# ----------------------------------------------------------------------------
fd <- data %>%
  select(sid, year, treat, l_homicide) %>%
  pivot_wider(names_from = year, values_from = l_homicide,
              names_prefix = "y") %>%
  mutate(diff = y2006 - y2005)

path4 <- feols(diff ~ treat, data = fd, cluster = ~ sid)
print(path4)


# ----------------------------------------------------------------------------
# PATH 5: Across-group difference (treated - control by year) on post dummy.
#         FWL mirror of Path 4 — same coefficient.
# ----------------------------------------------------------------------------
across <- data %>%
  group_by(year, treat, post) %>%
  summarise(y = mean(l_homicide, na.rm = TRUE), .groups = "drop") %>%
  pivot_wider(names_from = treat, values_from = y, names_prefix = "treat_") %>%
  mutate(gap = treat_1 - treat_0)
print(across)

path5 <- lm(gap ~ post, data = across)
print(summary(path5))


# ----------------------------------------------------------------------------
# Population-weighted versions (sanity check that weights propagate)
# ----------------------------------------------------------------------------
path2_w <- feols(
  l_homicide ~ post + treat + post:treat,
  data = data, cluster = ~ sid, weights = ~ popwt
)
print(path2_w)
