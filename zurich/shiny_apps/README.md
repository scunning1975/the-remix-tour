# Zurich — Shiny apps

Interactive demos for the mini-course.

## Bundled apps (in this folder)

- **Bacon-Decomposition/** — interactive Goodman-Bacon decomposition explorer. Use on Day 2 when introducing the TWFE problem.
- **Event-Study/** — interactive event-study plotter. Use on Day 1 (canonical pre-trends visualization) and Day 2 (modern event-study aggregation).

## External app (link only)

- **CBS** (`baconplus`)
  Source: <https://github.com/scunning1975/baconplus>
  Live: <https://scunning1975.github.io/baconplus/>

  Continuous-treatment DiD TWFE decomposition based on Callaway, Goodman-Bacon, Sant'Anna (v4). Uses 155-industry simulated tariff doses mimicking Lu–Yu (2015) Chinese tariff distribution. Shows weight-curve reconstruction, kernel bandwidth selection via slider, level + scaled weights, and TWFE coefficient reconstruction.

  **Use on Day 3** when introducing continuous-treatment DiD — the slider-based weight-curve view is the cleanest way to communicate why the TWFE coefficient is a non-obvious weighted average over dose levels.
