# Agent C — Deck Integration Audit

**Scope:** `glasgow/decks/covariates.tex` × `simulations/` × `_themes/remix_theme.R` × `remix.sty`.
**Verdict:** code blocks are sparse and mostly clean; figures are the weak link. The two Monte Carlo PNGs (`mc_dr_1.png`, `mc_dr_2.png`) and the IPW comparison PDF need to be regenerated through `remix_theme()` to match the rest of the deck.

## 1. Code-block inventory

Three `lstlisting` blocks total. All are `fragile` frames.

| Slide | Lines | Language | What it shows | Stripped enough? |
|---|---|---|---|---|
| L2 sim, line 417 (`pt_fails`) | 13 | R | seed, `data.frame`, treat/post, X moves on treated post, Y(0) = 10 + 2X + noise, `aggregate` | **Yes.** Reads like a recipe; no libraries, no plotting code. |
| L4-F4 sim, line 703 (`ipw_comparison`) | 17 | R | N, X1/X2, `plogis`, D, Y0, Y1 = Y0 + (1 + 0.5\*X1) — the switching equation is explicit — then Method A (IPW) and Method B (regression with phat) side by side | **Yes.** The two contrasting one-liners (`A <- ...` and `B <- ...`) are exactly the lesson. |
| L5-F5 DR-DiD, line 891 | 16 | R | `library(DRDID)` then the full named-argument call to `drdid()` | **Borderline.** This is an API demo, not a Y(0)/Y(1) DGP, so it's fine — but it's the *only* block that exposes options (`estMethod`, `boot`, `inffunc`). Acceptable for an API call. |

No `verbatim` blocks. No code shows the actual switching equation in two lines (`Y <- D*Y1 + (1-D)*Y0`) except the L4 block — that's the right pattern and the other two could adopt it but currently don't need it because they bypass the switch.

**The deck is doing well here.** Three code blocks across 1,537 lines, each short, each making one point. The simulations folder has the full versions (`comparing_did.do` is 173 lines, mostly banners and `display` lines — the *deck* shouldn't try to reproduce that).

## 2. Figure inventory

| Line | Figure | Source | Aesthetic |
|---|---|---|---|
| 442 | `pt_fails_in_y0.pdf` | ggplot (presumably) | Decent — palette unclear, but small enough to read |
| 689 | `ipw_comparison.pdf` | ggplot or coefplot | **Aesthetic unknown from code; needs check** |
| 964 | `mc_dr_1.png` | CI-2 carryover, **not remix** | **Out of style** |
| 1002 | `mc_dr_2.png` | CI-2 carryover, **not remix** | **Out of style** |
| 1281 | `hong_table.png` | scanned table from Hong (2013) | Out of style — unavoidable |
| 1294–95 | `Hong_1.pdf`, `Hong_2.pdf` | Hong (2013) published figures | Out of style — unavoidable |

The Hong figures are *historical artifacts* and Scott has flagged that they stay. The fixable problems are `mc_dr_1.png`, `mc_dr_2.png`, and probably `ipw_comparison.pdf` / `pt_fails_in_y0.pdf`.

## 3. Code-block consistency — proposed `\meta{...}` pattern

The deck already uses `\meta{...}` correctly in three places (lines 721, 932, 1025, 1490). Pattern is clean and consistent. Recommendation: **add `\meta{...}` under every code block and every estimator slide** with a relative path like:

```latex
\meta{Full simulation: \texttt{simulations/covariates/comparing\_did.do}}
```

**Missing meta breadcrumbs** that should be added:
- L2-F2j (line 417 R sim): add `\meta{Stata version: \texttt{simulations/covariates/comparing\_did.do}}`
- L2-F2l Spec A/Spec B table (line 456): add `\meta{Generated in: \texttt{simulations/covariates/comparing\_did.do}}`
- L5-MC2/MC4 tables (lines 936, 974): both should `\meta` to `simulations/covariates/covariates_monte_carlo.{do,R}` — currently only L5-MC1 (line 932) and L5-MC6 (line 1025) do.

The L5-F5 `drdid` block (line 891) has no `\meta` and should — the full live example lives in `comparing_did.do` lines 154–155.

## 4. Figure-aesthetic gap

The CI-2 `mc_dr_1.png` / `mc_dr_2.png` predate the remix theme and almost certainly use ggplot defaults (gray panel, light-blue fills, no cream background, no remixgreen). **They will visually clash** with the cream-background TikZ frames that immediately follow and precede them. This is the largest single visual inconsistency in the deck.

`pt_fails_in_y0.pdf` is described in CI-2 review as ggplot — likely also default theme. `ipw_comparison.pdf` is unknown but is the centerpiece of Lesson 4 and *must* be in-aesthetic.

## 5. Proposal — regenerate the four sim figures via `remix_theme()`

Yes, regenerate. The R machinery already exists; the marginal cost is one source pass per figure. Minimum pattern:

```r
source("/Users/scunning/the-remix-tour/_themes/remix_theme.R")

# after building the data frame `df` of sampling-distribution estimates:
ggplot(df, aes(x = estimate, fill = method)) +
  geom_density(alpha = 0.45, color = NA) +
  geom_vline(xintercept = truth, color = remix_color("charcoal"),
             linetype = "dashed", linewidth = 0.4) +
  scale_fill_remix_d() +
  labs(title = NULL, x = "ATT estimate", y = NULL,
       caption = "10,000 reps · N = 1,000 · dashed line = truth") +
  theme_remix(legend = "bottom")

remix_save("glasgow/decks/figures/mc_dr_1.pdf", width = 7.2, height = 4.2)
```

Note: switch from `.png` to `.pdf` (vector — sharper at projection scale) and update the four `\includegraphics` lines accordingly. Same recipe for `mc_dr_2`, `ipw_comparison`, `pt_fails_in_y0`. The simulations themselves (`covariates_monte_carlo.R`, the L4 IPW sim) already produce the underlying data — only the plotting layer changes.

**Title-as-assertion handled by the slide title (`DGP 1 --- both models correct`), so `theme_remix()` figures should have `title = NULL`** — let the frame title do the rhetorical work. Caption carries the metadata.

## 6. `\lstset` for slide code blocks

The deck already defines a global `\lstset` at line 27, and it's already remix-aligned: `keywordstyle=\color{accentdark}\bfseries`, `commentstyle=\color{warmgray}\itshape`, `backgroundcolor=\color{lightbg}`, `rulecolor=\color{warmgray!40}`. **This is good. Keep it.**

One inconsistency: the L2-F2j block (line 417) overrides with `frame=none`, while L4-F4 (line 703) and L5-F5 (line 891) inherit the global `frame=single`. Pick one. Recommendation: drop the per-block override on line 417 — the framed lightbg version reads as "code object" and is more consistent with the block visuals elsewhere. Also drop `basicstyle=\ttfamily\footnotesize,...` from line 417 since the global already sets footnotesize.

After cleanup, all three slide code blocks reduce to:

```latex
\begin{lstlisting}[language=R]
...
\end{lstlisting}
```

— inheriting the global style. That's the consistent slide look.

## Summary — recommended actions, in order

1. **Regenerate** `mc_dr_1`, `mc_dr_2`, `ipw_comparison`, `pt_fails_in_y0` via `theme_remix()` + `remix_save()`. Switch PNG → PDF. (Biggest visible win.)
2. **Add `\meta{...}` breadcrumbs** on L2-F2j, L2-F2l, L5-F5, L5-MC2, L5-MC4 pointing to the right `simulations/covariates/*.do` file.
3. **Strip the per-block `\lstset` override** on line 417 to inherit the deck-level style.
4. Hong figures — leave as-is; clearly historical, students will read them as quoted material.
