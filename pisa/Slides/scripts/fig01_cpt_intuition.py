"""
fig01_cpt_intuition.py
Two-panel figure: Conditional Parallel Trends
Left  — unconditional PT fails (high- vs low-education counties diverge)
Right — conditional PT holds within education strata

Output: ../figures/fig01_cpt_intuition.pdf
"""

import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib import rcParams

# ── Palette (matches pisa_theme.sty) ──────────────────────────────
PARCHMENT  = "#F6EDD6"
PISA_STONE = "#28221E"
ARNO_BLUE  = "#2A6496"
TERRACOTTA = "#B85A30"
TUSCAN_GOLD= "#C5922A"
CYPRESS    = "#4A7C59"
MORTAR     = "#8B7D6B"
MARBLE     = "#F0E8D4"

rcParams.update({
    "font.family"      : "serif",
    "font.size"        : 10,
    "axes.spines.top"  : False,
    "axes.spines.right": False,
    "axes.edgecolor"   : MORTAR,
    "axes.labelcolor"  : PISA_STONE,
    "xtick.color"      : MORTAR,
    "ytick.color"      : MORTAR,
    "text.color"       : PISA_STONE,
    "figure.facecolor" : PARCHMENT,
    "axes.facecolor"   : PARCHMENT,
    "savefig.facecolor": PARCHMENT,
})

years   = np.array([1995, 1997, 1999, 2001, 2003, 2005, 2007])
t_treat = 2001   # treatment starts here
pre  = years <= t_treat
post = years >  t_treat

# ══════════════════════════════════════════════════════════════════
# PANEL A — Unconditional PT fails
# High-education treated counties trend differently pre-treatment
# ══════════════════════════════════════════════════════════════════

# High-edu treated: downward pre-trend (opportunity cost of kids rises)
hi_treat = np.array([38, 36, 34, 32,  30, 28, 26])
# Low-edu control: flat pre-trend, slight post rise
lo_ctrl  = np.array([28, 28, 28, 28,  30, 31, 32])
# Low-edu treated (counterfactual, unobserved — dashed)
lo_treat_cf = np.array([28, 28, 28, 28, 30, 31, 32])   # same as control
# High-edu control (different pre-trend)
hi_ctrl  = np.array([36, 35, 34, 33,  32, 31, 30])

fig, axes = plt.subplots(1, 2, figsize=(10, 4.2), sharey=False)

# ── Panel A ────────────────────────────────────────────────────────
ax = axes[0]
ax.set_facecolor(PARCHMENT)

ax.plot(years, hi_treat, color=TERRACOTTA, lw=2.2,
        marker="o", ms=5, label="High-edu, treated")
ax.plot(years, hi_ctrl,  color=TERRACOTTA, lw=2.2,
        marker="s", ms=5, ls="--", alpha=0.6, label="High-edu, control")
ax.plot(years, lo_ctrl,  color=ARNO_BLUE,  lw=2.2,
        marker="o", ms=5, label="Low-edu, control")

# Shade treatment period
ax.axvspan(t_treat, 2007.3, color=TUSCAN_GOLD, alpha=0.08, zorder=0)
ax.axvline(t_treat, color=MORTAR, lw=0.9, ls=":")
ax.text(t_treat + 0.1, 40.2, "Treatment\nstarts", fontsize=8,
        color=MORTAR, va="bottom")

# PT violation arrow — pre-treatment gap widens
ax.annotate("", xy=(1999, hi_treat[2]), xytext=(1999, hi_ctrl[2]),
            arrowprops=dict(arrowstyle="<->", color=TERRACOTTA, lw=1.4))
ax.text(1999.1, (hi_treat[2] + hi_ctrl[2]) / 2,
        "Diverging\npre-trends", fontsize=8, color=TERRACOTTA)

ax.set_title("Unconditional PT fails\n(mixed-education comparison)",
             fontsize=10, fontweight="bold", color=PISA_STONE, pad=8)
ax.set_xlabel("Year", fontsize=9)
ax.set_ylabel("County birth rate (per 1,000 women 15–44)", fontsize=9)
ax.set_xticks(years)
ax.set_xticklabels(years, rotation=35, ha="right", fontsize=8)
ax.legend(fontsize=8, framealpha=0, loc="lower left")

# ══════════════════════════════════════════════════════════════════
# PANEL B — Conditional PT holds within education strata
# ══════════════════════════════════════════════════════════════════

# Within high-edu stratum: treated & control trend together pre-treatment
hi_t = np.array([38, 37, 36, 35,  31, 29, 27])   # treated — post-treatment falls more
hi_c = np.array([37, 36, 35, 34,  33, 32, 31])   # control — parallel pre-trend
# Within low-edu stratum: treated & control also parallel pre
lo_t = np.array([28, 28, 28, 28,  25, 24, 23])
lo_c = np.array([28, 28, 28, 28,  28, 28, 28])

ax = axes[1]
ax.set_facecolor(PARCHMENT)

ax.plot(years, hi_t, color=TERRACOTTA, lw=2.2,
        marker="o", ms=5, label="High-edu, treated")
ax.plot(years, hi_c, color=TERRACOTTA, lw=2.2,
        marker="s", ms=5, ls="--", alpha=0.65, label="High-edu, control")
ax.plot(years, lo_t, color=ARNO_BLUE,  lw=2.2,
        marker="o", ms=5, label="Low-edu, treated")
ax.plot(years, lo_c, color=ARNO_BLUE,  lw=2.2,
        marker="s", ms=5, ls="--", alpha=0.65, label="Low-edu, control")

# Counterfactual for high-edu treated — annotate ATT
cf_hi = np.array([38, 37, 36, 35, 34, 33, 32])    # same slope as control
ax.plot(years[post], cf_hi[post], color=TERRACOTTA,
        lw=1.4, ls=":", alpha=0.8)
ax.annotate("", xy=(2007, hi_t[-1]), xytext=(2007, cf_hi[-1]),
            arrowprops=dict(arrowstyle="<->", color=CYPRESS, lw=1.5))
ax.text(2007.05, (hi_t[-1] + cf_hi[-1]) / 2,
        "ATT\n(high)", fontsize=8, color=CYPRESS)

# shade treatment period
ax.axvspan(t_treat, 2007.3, color=TUSCAN_GOLD, alpha=0.08, zorder=0)
ax.axvline(t_treat, color=MORTAR, lw=0.9, ls=":")
ax.text(t_treat + 0.1, 39.5, "Treatment\nstarts", fontsize=8,
        color=MORTAR, va="bottom")

ax.set_title("Conditional PT holds\n(within each education stratum)",
             fontsize=10, fontweight="bold", color=PISA_STONE, pad=8)
ax.set_xlabel("Year", fontsize=9)
ax.set_ylabel("County birth rate (per 1,000 women 15–44)", fontsize=9)
ax.set_xticks(years)
ax.set_xticklabels(years, rotation=35, ha="right", fontsize=8)
ax.legend(fontsize=8, framealpha=0, loc="lower left")

fig.suptitle(
    "Conditioning on covariates rescues parallel trends",
    fontsize=12, fontweight="bold", color=PISA_STONE, y=1.01
)

plt.tight_layout()
plt.savefig("../figures/fig01_cpt_intuition.pdf",
            bbox_inches="tight", dpi=150)
print("Saved: ../figures/fig01_cpt_intuition.pdf")
