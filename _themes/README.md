# `_themes/` — Shared visual identity for The Remix tour

Every figure produced for the Summer 2026 tour should land in the same visual register as the slide deck. This folder is the single source of truth.

## Files

| File | What it is |
|---|---|
| `remix_theme.R` | ggplot2 theme + categorical/sequential/diverging color scales + a `remix_save()` wrapper for clean PDFs. |

(Stata `.scheme` file and Python/matplotlib equivalents may be added later. Until then, copy the hex codes below.)

## The palette (must match `zurich/decks/remix.sty`)

| Name | Hex | Use |
|---|---|---|
| `remixgreen` | `#40A848` | Primary accent — book cover green |
| `remixgreendark` | `#1F5C25` | Section dividers, deep accent |
| `remixgreenlight` | `#D9F0DB` | Tinted backgrounds, alert blocks |
| `charcoal` | `#2D3748` | Headers, emphasis, plot titles |
| `slate` | `#4A5568` | Body text |
| `forest` | `#276749` | Positive / secondary green |
| `ocean` | `#2B6CB0` | Links, secondary categorical |
| `warmgray` | `#718096` | Captions, axes, gridlines |
| `lightbg` | `#F7FAFC` | Subtle panel backgrounds |
| `cream` | `#FAF8F2` | Main background — matches slides |
| `oceanlight` | `#DCE9F5` | Example block background |
| `alertred` | `#C53030` | Warnings/negative — sparingly |

## R usage

```r
source("path/to/_themes/remix_theme.R")

library(ggplot2)
ggplot(d, aes(x = year, y = value, color = group)) +
  geom_line(linewidth = 1) +
  labs(title = "Treatment effect over time",
       subtitle = "Heterogeneous responses, 500 Monte Carlo runs",
       x = "year", y = NULL) +
  scale_color_remix_d() +
  theme_remix()
```

To save a figure with the tour's standard dimensions and cream background:

```r
remix_save("figures/my_plot.pdf")
```

## Available scales

- **Discrete** (categorical): `scale_color_remix_d()`, `scale_fill_remix_d()`
- **Continuous sequential**: `scale_color_remix_c()`, `scale_fill_remix_c()` — single-hue ramp from light to deep Remix green
- **Continuous diverging**: `scale_color_remix_div()`, `scale_fill_remix_div()` — ocean low → cream mid → remixgreen high

## Direct color lookup

```r
remix_color("remixgreen")   # "#40A848"
remix_color("ocean")        # "#2B6CB0"
```

## Discrete category ordering

The categorical palette is ordered by salience — the first category gets the accent green, the second gets ocean blue, etc. Put the most important comparison first.

```
1. remixgreen   #40A848   (your treatment, your main finding)
2. ocean        #2B6CB0   (the comparison)
3. charcoal     #2D3748   (third group)
4. warmgray     #718096   (de-emphasized)
5. forest       #276749   (additional)
```

## Principle: figures should look like the slide they sit on

Same cream background. Same charcoal title. Same gridline weight. The figure is not a separate object — it's part of the slide.

This means: when you compile the deck and look at slide N, the figure shouldn't pop visually. It should blend into the typography, anchored by the accent color where the eye needs to land.

## Reference

Style file: `/Users/scunning/the-remix-tour/zurich/decks/remix.sty`
Design principles: `/Users/scunning/Library/CloudStorage/Dropbox-MixtapeConsulting/scott cunningham/0.1 Mixtape Consulting/Workshops/2026/DESIGN_PRINCIPLES.md`
