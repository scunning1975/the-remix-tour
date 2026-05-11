# Tiebout-Roy Simulation — Weighting and Aggregation

The simulation behind the **"Sorting on δ can flip the sign of your answer"** slide in `basics.tex` (Lesson 3 — potential outcomes, weighting subsection).

Based on the Solon, Haider & Wooldridge (2015) framing: *the reason you weight in causal inference is different from why you weight in survey design*. Survey weights make estimates nationally representative. Causal-inference weights select your target parameter.

## The scenario

- 30 million people, 254 counties.
- Five large counties have 3M people each (15M total — Harris, Dallas, Tarrant, Bexar, Travis in our Texas illustration).
- 249 small counties share the remaining 15M (≈ 60K each).
- Individual treatment effects δᵢ vary; population mean E[δ] = 2.
- Two sorting mechanisms (different `.R` / `.do` files).

## Files

| File | Scenario |
|---|---|
| `tiebout_roy.R` / `.do` | Random sorting — every county is a random sample of the population. Person-weighted ATE = County-weighted ATE = 2. |
| `tiebout_roy2.R` / `.do` | Sort by δᵢ — high-effect people in big counties, low-effect (or negative-effect) people in small counties. Person-weighted ATE = 2, county-weighted ATE flips negative. |

## The punchline

Same data, same potential outcomes, same population mean of δ. **Two different weighting schemes, two different parameters, possibly two different signs.** Pick your parameter based on the question you're asking.

## Reference

Solon, G., Haider, S. J., & Wooldridge, J. M. (2015). "What Are We Weighting For?" *Journal of Human Resources*, 50(2), 301–316.

## Origin

Adapted from `Causal-Inference-2/Lab/Tiebout_roy/` (Scott's earlier teaching folder).
