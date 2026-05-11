## remix_theme.R
## ----------------------------------------------------------------------
## Shared ggplot2 theme + color scales for "The Remix" Summer 2026 tour.
## Matches the palette in /Users/scunning/the-remix-tour/zurich/decks/remix.sty
##
## Usage:
##   source("path/to/remix_theme.R")
##   ggplot(d, aes(x, y, color = group)) + geom_line() +
##     scale_color_remix_d() +
##     theme_remix()
## ----------------------------------------------------------------------

if (!requireNamespace("ggplot2", quietly = TRUE)) {
  stop("ggplot2 is required for remix_theme.R")
}

## ---- Palette (must match remix.sty) ----
remix_palette <- c(
  remixgreen      = "#40A848",  # primary accent (book cover)
  remixgreendark  = "#1F5C25",  # section dividers, deep accent
  remixgreenlight = "#D9F0DB",  # tinted backgrounds
  charcoal        = "#2D3748",  # headers, emphasis
  slate           = "#4A5568",  # body text
  forest          = "#276749",  # positive / secondary green
  ocean           = "#2B6CB0",  # links, secondary emphasis
  warmgray        = "#718096",  # captions, axes, gridlines
  lightbg         = "#F7FAFC",  # subtle panel
  cream           = "#FAF8F2",  # main background, matches slides
  oceanlight      = "#DCE9F5",  # alt block background
  alertred        = "#C53030"   # sparingly: warnings/negative
)

remix_color <- function(name) {
  if (!name %in% names(remix_palette)) {
    stop("Unknown remix color: ", name,
         ". Available: ", paste(names(remix_palette), collapse = ", "))
  }
  unname(remix_palette[name])
}

## ---- Discrete categorical (ordered by salience) ----
remix_categorical <- unname(remix_palette[c(
  "remixgreen", "ocean", "charcoal", "warmgray", "forest"
)])

## ---- Sequential single-hue (light cream-ish to deep Remix green) ----
remix_seq <- c(
  "#EEF7EE", "#CDE6CF", "#9DCFA1", "#65B26B",
  "#40A848", "#2E8634", "#1F5C25", "#143818"
)

## ---- Diverging (ocean low, cream mid, remixgreen high) ----
remix_div <- c(
  "#2B6CB0", "#7AA5D4", "#C2D4E8", "#FAF8F2",
  "#C2E5C5", "#7AC983", "#40A848", "#1F5C25"
)

## =================================================================
##                      ggplot2 scales
## =================================================================

scale_color_remix_d <- function(..., reverse = FALSE) {
  pal <- if (reverse) rev(remix_categorical) else remix_categorical
  ggplot2::discrete_scale("colour",
                          palette = function(n) pal[seq_len(n)], ...)
}

scale_fill_remix_d <- function(..., reverse = FALSE) {
  pal <- if (reverse) rev(remix_categorical) else remix_categorical
  ggplot2::discrete_scale("fill",
                          palette = function(n) pal[seq_len(n)], ...)
}

scale_color_remix_c <- function(...) {
  ggplot2::scale_color_gradientn(colours = remix_seq, ...)
}

scale_fill_remix_c <- function(...) {
  ggplot2::scale_fill_gradientn(colours = remix_seq, ...)
}

scale_color_remix_div <- function(...) {
  ggplot2::scale_color_gradientn(colours = remix_div, ...)
}

scale_fill_remix_div <- function(...) {
  ggplot2::scale_fill_gradientn(colours = remix_div, ...)
}

## =================================================================
##                      theme_remix()
## =================================================================
## - Cream background (matches title slides)
## - Subtle gridlines in warmgray
## - Charcoal title, warmgray subtitle/caption
## - Strip backgrounds tinted for facets
## - No legend by default (prefer direct labels)

theme_remix <- function(base_size = 11, base_family = "",
                        legend = c("none", "right", "bottom", "top", "left")) {
  legend <- match.arg(legend)

  ggplot2::theme_minimal(base_size = base_size, base_family = base_family) +
    ggplot2::theme(
      plot.background     = ggplot2::element_rect(fill = remix_palette["cream"],   color = NA),
      panel.background    = ggplot2::element_rect(fill = remix_palette["cream"],   color = NA),
      strip.background    = ggplot2::element_rect(fill = remix_palette["lightbg"], color = NA),

      plot.title          = ggplot2::element_text(face = "bold",
                                                  color = remix_palette["charcoal"],
                                                  size  = base_size * 1.25,
                                                  margin = ggplot2::margin(b = 6)),
      plot.subtitle       = ggplot2::element_text(color = remix_palette["warmgray"],
                                                  size  = base_size * 0.95,
                                                  margin = ggplot2::margin(b = 10)),
      plot.caption        = ggplot2::element_text(color = remix_palette["warmgray"],
                                                  size  = base_size * 0.8,
                                                  hjust = 0),
      plot.title.position = "plot",
      plot.caption.position = "plot",
      axis.title          = ggplot2::element_text(color = remix_palette["charcoal"],
                                                  size  = base_size * 0.95),
      axis.text           = ggplot2::element_text(color = remix_palette["slate"],
                                                  size  = base_size * 0.85),
      strip.text          = ggplot2::element_text(face = "bold",
                                                  color = remix_palette["charcoal"],
                                                  size  = base_size * 0.95),
      legend.title        = ggplot2::element_text(color = remix_palette["charcoal"],
                                                  size  = base_size * 0.85),
      legend.text         = ggplot2::element_text(color = remix_palette["slate"],
                                                  size  = base_size * 0.85),

      panel.grid.major    = ggplot2::element_line(color = remix_palette["warmgray"],
                                                  linewidth = 0.25),
      panel.grid.minor    = ggplot2::element_blank(),

      legend.position     = legend,
      legend.background   = ggplot2::element_rect(fill = remix_palette["cream"], color = NA),
      legend.key          = ggplot2::element_rect(fill = remix_palette["cream"], color = NA),

      plot.margin         = ggplot2::margin(14, 14, 12, 14)
    )
}

## =================================================================
##                      remix_save()
## =================================================================
remix_save <- function(filename, plot = ggplot2::last_plot(),
                       width = 7.2, height = 5.0, units = "in",
                       device = "pdf", ...) {
  d <- dirname(filename)
  if (!dir.exists(d) && d != "") dir.create(d, recursive = TRUE, showWarnings = FALSE)
  ggplot2::ggsave(filename, plot = plot,
                  width = width, height = height, units = units,
                  device = device, ...)
}

message("Remix ggplot2 theme loaded.\n  - theme_remix()\n  - scale_color_remix_d() / _c() / _div()\n  - scale_fill_remix_d() / _c() / _div()\n  - remix_save()")
