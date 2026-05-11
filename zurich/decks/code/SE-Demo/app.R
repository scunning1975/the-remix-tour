## app.R — Interactive SE Demo
## ----------------------------------------------------------------------
## A Shiny app that lets students dial within-cluster correlation (rho)
## and watch the over-rejection of vanilla / HC1 robust standard errors
## materialize in real time. Cluster-robust SE stays near nominal size.
##
## Companion to se_simulation.R (the static version).
##
## Run locally:
##   shiny::runApp("path/to/SE-Demo")
## ----------------------------------------------------------------------

suppressPackageStartupMessages({
  library(shiny)
  library(ggplot2)
  library(sandwich)
  library(lmtest)
})

source(file.path("..", "..", "..", "..", "_themes", "remix_theme.R"))

## ----- single replication -----
##   Two independent DGP knobs:
##   - rho:  within-cluster AR(1) correlation (the clustering problem)
##   - het:  D-correlated heteroskedasticity strength (the heteroskedasticity
##           problem) — treated obs have variance scaled by exp(het * D), so
##           het=0 means homoskedastic, het=1 means treated have ~e^2 ≈ 7x variance.
one_rep <- function(n_states, n_years, rho, het, sigma_e = 1.0, true_beta = 0.0) {
  state <- rep(seq_len(n_states), each = n_years)
  year  <- rep(seq_len(n_years), times = n_states)

  alpha_state <- rnorm(n_states, 0, 1)
  gamma_year  <- rnorm(n_years, 0, 0.3)

  ## AR(1) errors within state (homoskedastic innovations)
  eps <- numeric(n_states * n_years)
  init_sd <- if (rho >= 1 - 1e-6) sigma_e else sigma_e / sqrt(1 - rho^2)
  for (s in seq_len(n_states)) {
    idx <- which(state == s)
    e <- numeric(n_years)
    e[1] <- rnorm(1, 0, init_sd)
    if (n_years > 1) for (t in 2:n_years) e[t] <- rho * e[t-1] + rnorm(1, 0, sigma_e)
    eps[idx] <- e
  }

  treated_states <- sample(n_states, n_states %/% 2)
  treat_year     <- max(2, n_years %/% 2 + 1)
  D <- as.integer(state %in% treated_states & year >= treat_year)

  ## D-correlated heteroskedasticity — only the "het" slider scales this
  eps <- eps * exp(het * D)

  y <- alpha_state[state] + gamma_year[year] + true_beta * D + eps

  d <- data.frame(state = factor(state), year = factor(year), D = D, y = y)
  fit <- lm(y ~ D + state + year, data = d)
  bhat <- coef(fit)["D"]

  se_vanilla <- sqrt(diag(vcov(fit)))["D"]
  se_hc1 <- sqrt(diag(vcovHC(fit, type = "HC3")))["D"]
  se_cr  <- sqrt(diag(vcovCL(fit, cluster = ~state, type = "HC1")))["D"]

  c(beta = unname(bhat),
    se_vanilla = unname(se_vanilla),
    se_hc1     = unname(se_hc1),
    se_cr      = unname(se_cr))
}

## ----- Monte Carlo wrapper with a progress bar -----
run_mc <- function(n_states, n_years, rho, het, n_sim, true_beta = 0) {
  results <- matrix(NA_real_, nrow = n_sim, ncol = 4)
  colnames(results) <- c("beta", "se_vanilla", "se_hc1", "se_cr")
  withProgress(message = "Running Monte Carlo", value = 0, {
    for (i in seq_len(n_sim)) {
      results[i, ] <- one_rep(n_states, n_years, rho, het, true_beta = true_beta)
      if (i %% 25 == 0) incProgress(25 / n_sim, detail = paste(i, "/", n_sim))
    }
  })
  as.data.frame(results)
}

## ----- UI -----
ui <- fluidPage(
  tags$head(tags$style(HTML("
    body { background:#FAF8F2; color:#4A5568; font-family: Helvetica, Arial, sans-serif; }
    h1 { color:#2D3748; font-weight:700; }
    h3 { color:#2D3748; font-weight:600; }
    .well { background:#F7FAFC; border:0; }
    .stat-box { padding:10px 14px; border-radius:6px; margin-right:8px; display:inline-block;
                font-weight:600; color:#FAF8F2; min-width:170px; text-align:center; }
    .stat-good { background:#40A848; }
    .stat-bad  { background:#C53030; }
    .stat-meh  { background:#718096; }
    .stat-label { font-size:11px; opacity:0.85; font-weight:500; }
    .stat-value { font-size:22px; }
  "))),

  titlePanel("SE Demo: how clustering breaks vanilla and robust SEs"),

  sidebarLayout(
    sidebarPanel(
      h3("Data-generating process"),
      sliderInput("rho", "Within-cluster correlation ρ (clustering)",
                  min = 0, max = 0.95, value = 0.7, step = 0.05),
      sliderInput("het", "Heteroskedasticity strength (D-correlated)",
                  min = 0, max = 1.5, value = 0.5, step = 0.1),
      sliderInput("n_states", "Number of states (clusters)",
                  min = 10, max = 100, value = 40, step = 5),
      sliderInput("n_years", "Years per state",
                  min = 4, max = 30, value = 10, step = 1),
      sliderInput("n_sim", "Monte Carlo replications",
                  min = 50, max = 500, value = 200, step = 50),
      actionButton("go", "Run simulation",
                   style = "background:#40A848; color:#FAF8F2; font-weight:600; border:0; padding:10px 20px;"),
      hr(),
      tags$p(style = "font-size:12px; color:#718096;",
             "True effect = 0 (placebo). 200 reps ≈ 5s; 500 ≈ 15s.",
             br(), br(),
             tags$b("Two knobs, two problems:"),
             br(),
             "• ", tags$b("ρ = 0"), ", ", tags$b("het = 0"), " → all three are correct (5%)",
             br(),
             "• ", tags$b("ρ = 0"), ", ", tags$b("het > 0"), " → vanilla wrong; robust + CRVE OK",
             br(),
             "• ", tags$b("ρ > 0"), ", ", tags$b("het = 0"), " → vanilla = robust (both wrong); only CRVE OK",
             br(),
             "• ", tags$b("ρ > 0"), ", ", tags$b("het > 0"), " → both vanilla and robust wrong; only CRVE OK")
    ),

    mainPanel(
      h3("Rejection rates at α = 0.05 (nominal)"),
      uiOutput("rates"),
      hr(),
      plotOutput("dist_plot", height = "440px")
    )
  )
)

## ----- Server -----
server <- function(input, output, session) {

  mc_results <- eventReactive(input$go, {
    set.seed(20260511)
    run_mc(input$n_states, input$n_years, input$rho, input$het, input$n_sim)
  }, ignoreNULL = FALSE)

  ## Initialize on first load with default sliders
  observe({
    isolate({
      if (is.null(input$go) || input$go == 0) {
        ## Force a first run
        session$onFlushed(function() {
          shiny::updateActionButton(session, "go")
        }, once = TRUE)
      }
    })
  })

  output$rates <- renderUI({
    r <- mc_results()
    crit <- qnorm(0.975)
    rej_v <- mean(abs(r$beta / r$se_vanilla) > crit)
    rej_h <- mean(abs(r$beta / r$se_hc1) > crit)
    rej_c <- mean(abs(r$beta / r$se_cr)  > crit)

    cls <- function(p) {
      if (abs(p - 0.05) <= 0.025) "stat-good"
      else if (p > 0.075) "stat-bad"
      else "stat-meh"
    }

    stat_box <- function(label, p) {
      tags$div(class = paste("stat-box", cls(p)),
               tags$div(class = "stat-label", label),
               tags$div(class = "stat-value", sprintf("%.1f%%", 100*p)))
    }

    tagList(
      stat_box("Vanilla", rej_v),
      stat_box("HC3 (robust)", rej_h),
      stat_box("Cluster-robust", rej_c),
      tags$p(style = "margin-top:14px; color:#718096; font-size:12px;",
             "Green = within 2.5pp of nominal 5%. Red = >7.5%. Gray = mildly off.")
    )
  })

  output$dist_plot <- renderPlot({
    r <- mc_results()
    plot_df <- data.frame(
      method = factor(rep(c("Vanilla SE",
                            "HC3 robust SE",
                            "Cluster-robust SE (state)"), each = nrow(r)),
                      levels = c("Vanilla SE",
                                 "HC3 robust SE",
                                 "Cluster-robust SE (state)")),
      t_stat = c(r$beta / r$se_vanilla,
                 r$beta / r$se_hc1,
                 r$beta / r$se_cr)
    )

    ggplot(plot_df, aes(x = t_stat)) +
      geom_histogram(aes(y = after_stat(density), fill = method),
                     bins = 35, alpha = 0.85, color = remix_color("cream")) +
      stat_function(fun = dnorm,
                    color = remix_color("charcoal"),
                    linewidth = 0.7, xlim = c(-5, 5)) +
      geom_vline(xintercept = c(-1.96, 1.96),
                 color = remix_color("alertred"),
                 linewidth = 0.5, linetype = "dashed") +
      facet_wrap(~ method, ncol = 1) +
      scale_fill_remix_d() +
      scale_x_continuous(limits = c(-8, 8)) +
      guides(fill = "none") +
      labs(
        x = "t-statistic",
        y = "density",
        caption = "Charcoal curve: N(0,1) target. Dashed red: ±1.96. Wider than the curve = over-rejection."
      ) +
      theme_remix()
  }, bg = "#FAF8F2")
}

shinyApp(ui, server)
