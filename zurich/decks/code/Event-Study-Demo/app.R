## app.R — Event Study Explorer (Remix style)
## ----------------------------------------------------------------------
## A single-cohort event-study DGP toy. Students drag five sliders and
## watch (a) the data and (b) the event-study coefplot update in real
## time. The point: see how the event-study coefficients trace the true
## treatment effect when PT holds — and how non-zero pre-trend slope
## shows up as sloped pre-period coefficients.
##
## Designed to be light enough to run as a static shinylive build on
## GitHub Pages. Only uses: shiny, fixest, ggplot2, dplyr — all of
## which have WebAssembly builds in shinylive's package universe.
##
## Run locally:
##   shiny::runApp("path/to/Event-Study-Demo")
## ----------------------------------------------------------------------

suppressPackageStartupMessages({
  library(shiny)
  library(fixest)
  library(ggplot2)
  library(dplyr)
})

## ----- Remix palette (inlined so shinylive doesn't need _themes path) -----
remix <- list(
  remixgreen = "#40A848",
  forest     = "#276749",
  ocean      = "#2B6CB0",
  charcoal   = "#2D3748",
  slate      = "#4A5568",
  warmgray   = "#718096",
  cream      = "#FAF8F2",
  lightbg    = "#F7FAFC",
  alertred   = "#C53030"
)

## ----- Theme function -----
theme_remix_app <- function(base_size = 13) {
  theme_minimal(base_size = base_size, base_family = "Helvetica") +
    theme(
      text             = element_text(color = remix$slate),
      plot.title       = element_text(face = "bold", color = remix$charcoal, size = base_size + 2),
      plot.subtitle    = element_text(color = remix$warmgray, size = base_size - 1),
      plot.caption     = element_text(color = remix$warmgray, size = base_size - 3,
                                      hjust = 0, margin = margin(t = 6)),
      axis.title       = element_text(color = remix$charcoal, size = base_size - 1),
      axis.text        = element_text(color = remix$slate),
      panel.grid.major = element_line(color = "#E2E8F0", linewidth = 0.3),
      panel.grid.minor = element_blank(),
      plot.background  = element_rect(fill = remix$cream, color = NA),
      panel.background = element_rect(fill = remix$cream, color = NA),
      legend.position  = "bottom",
      legend.title     = element_blank()
    )
}

## ----- Single-cohort DGP -----
simulate_panel <- function(n_units = 200, panel_start = 2010, panel_end = 2025,
                           treat_year = 2018, share_treated = 0.5,
                           te = 1.0, te_slope = 0.0, pre_slope = 0.0,
                           sigma_unit = 1.0, sigma_e = 0.5, seed = 20260511) {
  set.seed(seed)
  years <- panel_start:panel_end
  n_t   <- length(years)

  ## unit-level fixed effects
  unit_fe <- rnorm(n_units, 0, sigma_unit)
  treated <- rbinom(n_units, 1, share_treated)

  ## panel skeleton
  df <- expand.grid(unit = seq_len(n_units), year = years)
  df$treated  <- treated[df$unit]
  df$unit_fe  <- unit_fe[df$unit]

  ## relative year (Inf for never-treated)
  df$rel_year <- ifelse(df$treated == 1, df$year - treat_year, Inf)

  ## year fixed effects (small)
  year_fe <- rnorm(n_t, 0, 0.1)
  df$year_fe <- year_fe[match(df$year, years)]

  ## true treatment effect: level + slope after treatment
  df$te_true <- ifelse(df$treated == 1 & df$year >= treat_year,
                       te + te_slope * (df$year - treat_year),
                       0)

  ## pre-trend bias: treated units have a deterministic linear trend that
  ## starts at panel_start and accumulates. When pre_slope == 0, PT holds.
  df$pre_bias <- ifelse(df$treated == 1,
                        pre_slope * (df$year - panel_start),
                        0)

  ## outcome
  df$y <- df$unit_fe + df$year_fe + df$pre_bias + df$te_true +
          rnorm(nrow(df), 0, sigma_e)
  df
}

## ----- True effect curve for overlay on coefplot -----
true_effect_curve <- function(treat_year, te, te_slope, pre_slope, k_max = 8) {
  tibble::tibble(
    rel_year = -k_max:k_max,
    true_te  = ifelse(rel_year >= 0, te + te_slope * rel_year, 0),
    # If pre_slope != 0, the "true" pre-period coefs (relative to t=-1) are
    # also sloped — that's what creates the visible pre-trend warning.
    true_pre = pre_slope * (rel_year - (-1))  # relative to t=-1 baseline
  ) |>
  dplyr::mutate(true_full = true_te + true_pre)
}

## ----- Run event-study TWFE regression -----
## Control units get rel_year_capped = -1 (the reference category) so they
## stay in the regression to identify the year fixed effects, but contribute
## zero to any event-study coefficient.
run_es <- function(df, k_max = 8) {
  rel_capped <- pmax(pmin(df$rel_year, k_max), -k_max)
  df$rel_year_capped <- ifelse(df$rel_year == Inf, -1, rel_capped)
  fit <- fixest::feols(
    y ~ i(rel_year_capped, ref = -1) | unit + year,
    data    = df,
    cluster = ~unit
  )

  co <- broom::tidy(fit, conf.int = TRUE)
  if (nrow(co) == 0) return(NULL)
  co$rel_year <- as.numeric(sub("rel_year_capped::", "", co$term))
  co <- co[!is.na(co$rel_year), ]
  baseline <- data.frame(
    rel_year  = -1,
    estimate  = 0,
    conf.low  = 0,
    conf.high = 0
  )
  rbind(
    data.frame(
      rel_year  = co$rel_year,
      estimate  = co$estimate,
      conf.low  = co$conf.low,
      conf.high = co$conf.high
    ),
    baseline
  )
}

## ----- UI -----
ui <- fluidPage(
  tags$head(tags$style(HTML(sprintf("
    body { background: %s; color: %s; font-family: Helvetica, Arial, sans-serif; }
    h1, h2, h3 { color: %s; font-weight: 700; }
    h2 { font-size: 22px; margin-top: 18px; }
    .well { background: %s; border: 0; border-radius: 6px; }
    .scott-tagline { color: %s; font-size: 13px; margin-bottom: 12px; }
  ", remix$cream, remix$slate, remix$charcoal, remix$lightbg, remix$warmgray)))),

  titlePanel(
    div(
      h1("Event Study Explorer", style = sprintf("color:%s;", remix$charcoal)),
      div(class = "scott-tagline",
          "Single-cohort DiD. Adjust the DGP, watch the event-study coefficients trace the truth. ",
          "When pre-trend slope is non-zero, pre-period coefs slope too — that's the falsification signal."),
      div(class = "scott-tagline",
          tags$em("From Cunningham, ", tags$i("Causal Inference: The Remix"), " — Zurich Day 1, May 11, 2026."))
    )
  ),

  sidebarLayout(
    sidebarPanel(width = 4,
      h3("Data-generating process"),
      sliderInput("treat_year", "Treatment year", value = 2018,
                  min = 2012, max = 2023, step = 1, sep = ""),
      sliderInput("te", "True treatment effect (level)",
                  value = 1.0, min = -3, max = 3, step = 0.25),
      sliderInput("te_slope", "True effect slope (per year, post-treatment)",
                  value = 0.0, min = -0.5, max = 0.5, step = 0.05),
      sliderInput("pre_slope", "Pre-trend slope (treated units), violates PT when nonzero",
                  value = 0.0, min = -0.3, max = 0.3, step = 0.02),
      sliderInput("n_units", "Number of units", value = 200,
                  min = 50, max = 500, step = 50),
      sliderInput("sigma_e", "Noise (SD of error)", value = 0.5,
                  min = 0.1, max = 2.0, step = 0.1),
      hr(),
      tags$p(style = sprintf("font-size:12px; color:%s;", remix$warmgray),
             tags$b("How to drive:"), br(),
             "1. Start with all sliders at default. The event-study coefs should trace the true effect.", br(),
             "2. Add post-treatment slope. Watch the staircase appear.", br(),
             "3. Add a pre-trend slope. Watch the pre-period coefs slope away from zero — that's the failed gut-check.")
    ),

    mainPanel(width = 8,
      h2("The data (treated vs. control averages over time)"),
      plotOutput("dgp_plot", height = "300px"),
      h2("Event-study coefficients (TWFE, 95% CI clustered at unit)"),
      plotOutput("es_plot", height = "330px"),
      tags$div(style = sprintf("color:%s; font-size:12px; margin-top:8px;", remix$warmgray),
               tags$em("Solid line: estimated event-study coefficient with 95% CI. Dashed line: the true treatment-effect curve. Vertical dashed line: treatment date. ",
                       "Pre-period coefficients should sit on zero if PT holds."))
    )
  )
)

## ----- Server -----
server <- function(input, output, session) {

  df_react <- reactive({
    simulate_panel(
      n_units   = input$n_units,
      treat_year= input$treat_year,
      te        = input$te,
      te_slope  = input$te_slope,
      pre_slope = input$pre_slope,
      sigma_e   = input$sigma_e
    )
  })

  output$dgp_plot <- renderPlot({
    df <- df_react()
    avg <- df |>
      mutate(group = ifelse(treated == 1, "Treated", "Control")) |>
      group_by(group, year) |>
      summarise(y = mean(y), .groups = "drop")

    ggplot(avg, aes(x = year, y = y, color = group, linetype = group)) +
      geom_vline(xintercept = input$treat_year - 0.5,
                 color = remix$warmgray, linetype = "dashed", linewidth = 0.5) +
      annotate("text", x = input$treat_year - 0.5, y = max(avg$y),
               label = "Treatment", color = remix$warmgray,
               vjust = -0.6, hjust = -0.1, size = 3.6, fontface = "italic") +
      geom_line(linewidth = 1.0) +
      geom_point(size = 1.6) +
      scale_color_manual(values = c("Treated" = remix$remixgreen,
                                    "Control" = remix$ocean)) +
      scale_linetype_manual(values = c("Treated" = "solid",
                                       "Control" = "longdash")) +
      labs(x = NULL, y = "mean(y)") +
      theme_remix_app()
  }, bg = remix$cream)

  output$es_plot <- renderPlot({
    df <- df_react()
    es <- run_es(df, k_max = 8)
    if (is.null(es)) return(NULL)
    truth <- true_effect_curve(input$treat_year, input$te, input$te_slope,
                               input$pre_slope, k_max = 8)

    ggplot(es, aes(x = rel_year, y = estimate)) +
      geom_hline(yintercept = 0,
                 color = remix$charcoal, linetype = "dashed", linewidth = 0.4) +
      geom_vline(xintercept = -0.5,
                 color = remix$warmgray, linetype = "dashed", linewidth = 0.4) +
      geom_line(data = truth, aes(x = rel_year, y = true_full),
                color = remix$alertred, linewidth = 0.7, linetype = "longdash") +
      geom_linerange(aes(ymin = conf.low, ymax = conf.high),
                     color = remix$forest, linewidth = 0.6) +
      geom_point(color = remix$forest, size = 2.4) +
      scale_x_continuous(breaks = -8:8) +
      labs(x = "Event time (rel_year)", y = "Estimate",
           caption = "Forest dots/bars: TWFE event-study coefficient with 95% CI clustered at unit. Red dashed: true effect curve.") +
      theme_remix_app()
  }, bg = remix$cream)
}

shinyApp(ui = ui, server = server)
