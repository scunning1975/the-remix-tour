# Agent C — Voice & Trap audit

**Auditor:** Agent C (one of three parallel auditors)
**Deck:** `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex`
**Date:** 2026-05-12
**Scope:** (1) draft three "A student asks…" slides for L6-F6, L7-F4a, L7-F4d; (2) audit L4 ("The Trap") against CI-2 and propose what's missing.

---

## TL;DR

1. The three rhetorical-frame slides are drafted below as drop-in LaTeX. Each is one question, one answer, one residue line — under 9 lines of meat. Insertion points: after `L6-F6` (line ~1058), after `L7-F4a` (line ~1211), after `L7-F4d` (line ~1267).
2. **L4 is in good shape.** The remix deck already contains pedagogy that CI-2 does not have. CI-2's `02-Covariates.tex` never explicitly names the pscore-as-regressor trap; it derives DR and notes "we control for X twice — once weight, once regression" but never warns students against the natural temptation to write `lm(Y ~ D + phat)`. The remix L4 is **novel and correct**, with a working simulation (`code/IPW-Demo/ipw_simulation.R`) and a figure (`figures/ipw_comparison.pdf`).
3. **What L4 is missing:** it has the simulation, but it lacks an **intuitive mechanical explanation** of *why* the pscore-as-regressor regression is biased — i.e., what the OLS algebra is actually doing when you write `lm(Y ~ D + phat)`. The current intuition slide (F5) says "different uses, different assumptions" but stops short of the one-line algebraic crux: **additive regression imposes a single slope on $D$, so $\tau$ is forced constant across $\widehat{p}(X)$ — and the bias is exactly the covariance between $\tau(X)$ and $D$ within strata of $\widehat{p}$.** A short slide adding this would close the loop. Proposal in §3 below.

---

## 1. Drop-in LaTeX for the three "A student asks…" slides

All three use the remix.sty conventions confirmed in the stylesheet:
- `\highlight{...}` → bold accent color (defined as `accent`, lines 196 of remix.sty)
- `\meta{...}` → small warmgray italic for citations
- `\pullquote{Text}{Attribution}` → for the student framing (this is the rhetorical convention Scott already uses on L4-F1 with `\pullquote{...}{The audience, right now}` and L7-F4a with `\pullquote{...}{Anyone trying to use Hong in their own paper}`)

I deliberately did **not** invent a new macro. The student-framing comes through `\pullquote` with attribution to "A student, raising a hand" — matching the deck's existing voice. Frame titles are assertions (not questions), per Scott's rule that "titles are claims, not labels."

### Slide α — after L6-F6 (the `X_{t-1}` choice)

```latex
%% ---------- L6-F6a: A student asks — why X_{t-1}, not X_t? ----------
\begin{frame}{Pre-treatment $X$ is uncontaminated --- post-treatment $X$ is not}
\vspace{0.4em}
\pullquote{Why $X_{t-1}$ and not $X_t$? You're throwing away the most recent data point.}{A student, raising a hand}
\vspace{0.4em}
\begin{itemize}\small
  \item $X_t$ sits \highlight{downstream of treatment}. If the policy moves $X$ --- even a little --- you've controlled for a \textit{post-treatment outcome}.
  \item Conditioning on a post-treatment variable doesn't reduce bias. It \highlight{re-introduces} bias --- the bad-controls problem (Angrist-Pischke 2009, Ch.\ 3).
  \item $X_{t-1}$ is settled before $D$ is assigned. It carries the selection information without carrying any of the treatment.
\end{itemize}
\vspace{0.3em}
\begin{center}
\small\color{warmgray}\itshape
The rule generalizes: \;condition on the latest pre-treatment value, never the contemporaneous one.
\end{center}
\meta{Caetano \& Callaway (2024), \S 3; classic ``bad controls'' point goes back to Rosenbaum (1984).}
\end{frame}
```

**Voice check.** Question is concrete and slightly accusing ("you're throwing away data") — the way an actual sharp student would push. Answer lands in two beats: name the mechanism (downstream of treatment), then name the diagnosis (bad-controls problem). Closing line generalizes.

---

### Slide β — after L7-F4a (the post-period treated estimand)

```latex
%% ---------- L7-F4a-bis: A student asks — why this estimand? ----------
\begin{frame}{The post-period treated is the population the policy is for}
\vspace{0.4em}
\pullquote{Why average $\tau(X)$ over the post-period treated? Why not the pre-period treated, or both?}{A student, raising a hand}
\vspace{0.4em}
\begin{itemize}\small
  \item The post-period treated is \highlight{who actually got the policy}. Whatever number you report is implicitly about them.
  \item Sant'Anna-Zhao's $\tau_{sz}$ averages over the \textit{pooled} (pre $+$ post) treated --- a population that doesn't correspond to any policy decision.
  \item If $\tau(X)$ is heterogeneous and the post-period treated are a different mix from the pre-period treated, $\tau_{sz}$ answers a question \highlight{nobody asked}.
\end{itemize}
\vspace{0.3em}
\begin{center}
\small\color{warmgray}\itshape
Pick the estimand that matches the counterfactual you actually want to compare.
\end{center}
\meta{Sant'Anna \& Xu (2023), \S 2; bias decomposition Eq.\ 2.4.}
\end{frame}
```

**Voice check.** The student's question is the obvious next thing a thoughtful person asks: "why this one of three available targets?" The answer is brutally clear: because policy is forward-looking. The middle bullet does the work of explaining what SZ's pooled estimand actually is — and why it's strange when composition shifts. Closing line is a portable principle.

---

### Slide γ — after L7-F4d (the Hausman test in Sequeira)

```latex
%% ---------- L7-F4d-bis: A student asks — was SX even useful? ----------
\begin{frame}{Failing to reject \textit{is} the validation --- that's the point}
\vspace{0.4em}
\pullquote{The Hausman test failed to reject. So SX wasn't really doing anything here, right?}{A student, raising a hand}
\vspace{0.4em}
\begin{itemize}\small
  \item Wrong frame. The test isn't a switch that turns SX ``on'' when it rejects. \highlight{It's a diagnostic that tells you whether composition mattered for your ATT.}
  \item In Sequeira: $p = 0.338$ \textit{is} the result. It says ``the composition correction would have moved the number, but didn't enough to matter.''
  \item In Hong's Napster setting --- richer adopters in 1996, mass-market by 2001 --- it would have rejected. \highlight{Same test. Different application. Different verdict.}
\end{itemize}
\vspace{0.3em}
\begin{center}
\small\color{warmgray}\itshape
You don't get to know which world you're in until you run the test. \;That's why you run it.
\end{center}
\meta{Sant'Anna \& Xu (2023), Theorem 4.1; Sequeira (2016) for the application.}
\end{frame}
```

**Voice check.** Student misconception is the most common one — confusing a non-rejection with "the method failed." Answer reframes: SX is doing exactly the work it's designed to do (telling you the answer is robust to composition in *this* application, but not necessarily in others). The Hong comparison lands the punch. Closing residue line is portable.

---

## 2. Insertion mechanics

Three single `\begin{frame}...\end{frame}` blocks. Drop after the named landing slides:

| Slide | Insert after line | Notes |
|---|---|---|
| α | 1058 (end of `L6-F6` AIPW frame) | Same lesson; reinforces the punctual claim |
| β | 1211 (end of `L7-F4a` estimand frame) | Sets up F4b (Hausman test) cleanly |
| γ | 1267 (end of `L7-F4d` SADC application frame) | Bridges to F4e (validate vs. select) |

Slides α and γ each take ~8 lines of meat. Slide β takes ~7. All three are below the rhetoric guide's "wall of sentences" tripwire (three+ prose sentences) — each uses a leading question, three bulleted beats, and one residue line.

---

## 3. Audit of L4 ("The Trap")

### 3.1 What L4 currently does

Six frames covering the temptation, the math, the simulation, the code, the intuition, and the disease name. Sequence:

| Frame | Title | What it does |
|---|---|---|
| F1 | "A natural temptation" | Sets up the audience's instinct: pscore as scalar → just regress on it |
| F2 | "What that regression actually assumes" | Shows the equation; names "constant $\tau$ across $\widehat{p}(X)$" as the hidden assumption |
| F3 | "A simulation makes it visible" | Bias plot from 500 reps; Method B has ~$-10\%$ bias |
| F4 | "The simulation, one screen of R" | 12-line R code: DGP, two estimators |
| F5 | "Weight versus regressor — different uses of the same scalar" | The conceptual reframe |
| F6 | "Name the disease: additive-control-side bias" | Bridges to L6's hidden linearity bias |

This is **already a strong section**. It has design (the assumption being imposed), evidence (the simulation), code (replicable), and a generalization (the disease name). F3 and F4 are particularly load-bearing because they show the trap is not subtle — it has a real-data signature you can demonstrate in 12 lines.

### 3.2 Comparison to CI-2

I read `/Users/scunning/Causal-Inference-2/Slides/Tex/02-Covariates.tex` end to end on this point. Grep for "regressor," "control for pscore," "trap," etc. returns nothing relevant. The relevant CI-2 frames are:

- Line 588: "Double Robust DR" — sets up DR as "two chances to be wrong"
- Lines 605–632: DR-DiD derivation with the formula and the line: *"Notice how the model controls for $X$: you're weighting the adjusted outcomes using the propensity score. … The reason you control for $X$ twice is because you don't know which model is right."*

CI-2 **never names the pscore-as-regressor trap**. A reader of CI-2 could leave the lecture believing that "DR = IPW + a regression control" — exactly the misreading that Scott's remix L4-F5 explicitly warns against ("\highlight{That's wrong}"). So:

**L4 is doing pedagogical work CI-2 doesn't do.** It's not just a translation of CI-2 — it fills a real hole. The remix improves on CI-2 here.

### 3.3 Does L4 explain *why* pscore-as-regressor fails?

**Mathematically: partly.** F2 names the constraint imposed by additivity (no $D \times X$ interaction → constant $\tau$ across $\widehat{p}(X)$). This is correct, but a student could read F2 and ask: "OK, but the regression *should* still recover the average $\tau$, right? Why specifically biased *down*?" L4 doesn't fully answer that.

**Intuitively: yes.** F5's "weight vs. regressor" framing is solid. The pscore as a tool with two uses lands.

**By simulation: yes.** F3's figure shows the bias is real and persistent (it's not a finite-sample issue).

### 3.4 What L4 is missing — the algebraic crux

The piece that's missing is **why the bias goes in the direction it does**. The current F3 caption says "bias $\approx -10\%$" — but doesn't say *why negative*. A sharp student will ask: "Why is the regression biased *downward* specifically? Couldn't it have been upward?"

The answer is mechanical and worth one slide:

When you run `lm(Y ~ D + phat)`, OLS finds the $\tau$ that solves the normal equation projecting $Y$ onto $D$ after partialling out $\widehat{p}$. In the heterogeneous-effect DGP, $\tau(X) = 1 + 0.5 X_1$ and $D$ is selected on $X_1$ (high $X_1$ → high $\widehat{p}$ → more likely $D=1$). So the treated subsample is over-weighted on high-$X_1$ observations *and* has higher individual $\tau_i$ in expectation.

But OLS doesn't recover that conditional-mean ATT. OLS finds the slope on $D$ such that the residual $Y - \tau D - \gamma \widehat{p}$ is uncorrelated with $D$ within strata of $\widehat{p}$. Within a stratum of $\widehat{p}$, treated and control units have similar $X_1$ on average — by Rosenbaum-Rubin, this is *the right balancing condition* — but the regression then averages the within-stratum mean differences using OLS weights, which over-weight strata where the treatment/control variance is large, not strata that match the post-period treated distribution. The result: a weighted average of within-stratum mean differences that **doesn't equal the ATT** when $\tau$ varies with $X_1$.

That's the algebraic statement of "constant $\tau$ is being imposed, so the heterogeneity gets crushed into the OLS-weighted average." The sign of the bias depends on how $\tau(X)$ and the OLS variance-weight schedule line up. In this DGP it happens to be negative; in others it could be positive. **The bias is real, not just possible, but its sign is data-dependent.**

### 3.5 Proposed addition — one slide, drop after L4-F3

This is the slide I'd add — it answers "why negative" before F4 (the code) lands. It keeps L4 at 7 frames instead of 6, which is fine for a 75-minute lecture.

```latex
%% ---------- L4-F3b: A student asks — why is the bias negative? ----------
\begin{frame}{The bias has a sign --- and the sign is the heterogeneity OLS can't see}
\vspace{0.4em}
\pullquote{Why is Method B biased \textit{downward} by 10\%? Couldn't it have gone the other way?}{A student, raising a hand}
\vspace{0.4em}
\begin{itemize}\small
  \item OLS chooses $\widehat\tau$ so the residual is uncorrelated with $D$ \textit{within strata of $\widehat{p}$}. \\
        That's Rosenbaum-Rubin's balancing condition --- the \highlight{right} balancing condition.
  \item But the OLS-weighted average of within-stratum ATEs is \textbf{not} the ATT. It over-weights strata with high $D$-variance, not strata that match the treated $X$-distribution.
  \item Here, $\tau(X) = 1 + 0.5 X_1$ and treatment selects \textit{on} $X_1$. \;Treated units have higher $\tau_i$; OLS doesn't keep them weighted that way. \highlight{Down.}
\end{itemize}
\vspace{0.3em}
\begin{center}
\small\color{warmgray}\itshape
The sign depends on how $\tau(X)$ and OLS's variance weights co-move. \;The \textit{existence} of bias does not.
\end{center}
\meta{See Angrist (1998); S{\l}oczy\'nski (2022) for the OLS-vs-ATT weight gap.}
\end{frame}
```

**Why I'd add this.** Right now F3 → F4 jumps from "look, the bias is real" to "here's the code that produced it." A student who buys F2's argument ("constant $\tau$ is being imposed") might still not understand why the simulation produced the specific number it did. The Słoczyński (2022) framing — OLS-weighted average vs. ATT weights — is the cleanest one-slide answer.

If Scott decides to skip this addition, **L4 is still a strong section**. The simulation does enough work that the directional question can be answered orally. But the slide closes a real pedagogical loop.

### 3.6 Other L4 observations

- **F4 (the code slide) is the right thing to do** — students who run this code themselves will internalize the trap. The 12-line R block is the minimum to make it concrete.
- **F5's block on "DR is not IPW + regression control"** is gold. This is the *exact* misreading of CI-2 that the remix L4 was built to prevent. Keep it.
- **F6's name-the-disease move** (`additive-control-side bias`) is a remix invention. CI-2 has no analogous frame. It's effective because it gives the bias a portable label that L6 then leverages ("hidden linearity bias is the same disease, different costume"). Keep it.

---

## 4. Files referenced

- `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex` — deck under audit (1368 lines)
- `/Users/scunning/the-remix-tour/glasgow/decks/remix.sty` — style conventions (`\highlight`, `\meta`, `\pullquote` defined lines 196–211)
- `/Users/scunning/the-remix-tour/glasgow/decks/code/IPW-Demo/ipw_simulation.R` — the L4 simulation (already exists)
- `/Users/scunning/the-remix-tour/glasgow/decks/figures/ipw_comparison.pdf` — the L4 figure (already exists)
- `/Users/scunning/Causal-Inference-2/Slides/Tex/02-Covariates.tex` — CI-2 deck for comparison
- `/Users/scunning/Library/CloudStorage/Dropbox-MixtapeConsulting/scott cunningham/0.1 Mixtape Consulting/Workshops/2026/readings/Caetano_Callaway_2024_TimeVaryingCovariates_arxiv2406.15288_text.md` — CC reading
- `/Users/scunning/Library/CloudStorage/Dropbox-MixtapeConsulting/scott cunningham/0.1 Mixtape Consulting/Workshops/2026/readings/SantAnna_DiD_CompositionalChanges_text.md` — SX reading
- `/Users/scunning/mixtapetools/presentations/rhetoric_of_decks.md` — rhetoric guide

---

## 5. Closing assessment

The deck's L4 is the strongest piece of original pedagogy in the covariates remix. It plugs a hole CI-2 has — that "DR controls for X twice, once as weight, once as regressor" is a sentence a careful listener could misread as endorsing pscore-as-regressor. The remix names the trap, simulates it, codes it, and gives it a portable name. The one missing piece is the algebraic-direction question (§3.4–3.5); whether to add it depends on how much time Scott has.

The three student-asks slides for L6-F6, L7-F4a, L7-F4d are clean drop-ins. They use the existing `\pullquote` convention and don't require any style changes. Each closes a question a sharp student would ask and that the current frames don't fully land.

End of report.
