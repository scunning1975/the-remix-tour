# Agent A — Algebraic-Style Audit of `covariates.tex`

Benchmark: `Causal-Inference-2/Slides/Tex/02-Covariates.tex` and `01-Basics.tex`.

## 1. The 7-step TWFE-with-X / 4-step Y^0 trend proofs (covariates.tex L234–408)

**Matches Scott's style well.** Breaking the proof across step 1–step 8 frames, one
substitution per slide, with the `\boxed{}` constraint on L375 and the warmgray
margin commentary, is exactly the pacing CI-2 uses. Step 3 (L286–293) explicitly
introduces $\beta_1, \beta_2$ inside a `\boxed{}` before subtracting — that is a
faithful echo of CI-2's "Collecting terms" frame (CI-2 L713–733). Steps 6–7 cancel
$\alpha_1, \alpha_3 D$ with greyed-out color — also Scott-coded.

**Where it rushes.** Three places:

- **Step 1 (L247–250) is the single biggest skip.** Scott in CI-2 L684–688 writes
  the conditional PT identity in four lines, each one a labeled rearrangement
  ("PT $\Rightarrow$ split the difference $\Rightarrow$ rearrange $\Rightarrow$
  apply switching equation"). The Glasgow version collapses all of that into one
  word, "Rearrange," then drops the answer. The student does not see the algebra
  happen — they see the input and the output.
- **Step 2 (L262–266)** asserts the three conditional means with no derivation. CI-2
  L754–759 actually writes out the four cells $X_{11}, X_{10}, X_{01}, X_{00}$ with
  the time and treatment dummies plugged in. Here they appear fully baked.
- **Step 7 (L370–375)** subtracts $\alpha_2$ and produces the constraint in one
  beat. CI-2 (L767–781) walks the DiD subtraction across two displayed eqnarrays
  before isolating the $X$ terms — slower, more visible.

## 2. DR-DiD formula, L5 (covariates.tex L811–826) vs CI-2 L605–632

**The Glasgow frame states the formula; CI-2 derives the intuition.** CI-2 spends
**two consecutive frames** on the same formula: the first defines
$\mu_{d,\Delta}, \mu_{d,t}, p(X), \Delta Y$ piece by piece (L611–615); the second
delivers the punchline "the reason you control for $X$ twice is because you don't
know which model is right" (L629). The Glasgow version compresses both frames into
one and never says "controlling for $X$ twice." The component glossary on L820–824
labels $p(X)$ and $\mu_0(X)$ but does not unpack $D/E[D]$ as the treated-share
normalizer, and does not unpack why the second weight is itself normalized by its
own expectation (the Hájek correction). Scott's proof-next-slide promise on L824
is fulfilled by a clean Case A / Case B argument (L828–856), which is good — but
it presupposes the reader already trusts the formula. CI-2's two-frame approach
*earns* that trust first.

## 3. Step-1 conditional PT identity (L242–250)

Compressed. The "split the difference" line and the "apply switching equation"
line — both visible in CI-2 L685–688 — are missing. There is no `\underbrace{}`,
no `\textcolor{red}`-flagged switching substitution. This is the one slide where
the deck most departs from CI-2's "one move per line" cadence.

## 4. Algebraic moves CI-2 uses that Glasgow skips

- **The "add a zero" move with `\underbrace{...}_{\text{Adding zero}}` and red
  color**, signature of 01-Basics L541–554 and L852–867. Never appears in
  covariates.tex.
- **Four-cell expansion $X_{11}, X_{10}, X_{01}, X_{00}$** (CI-2 L754–759). Glasgow
  jumps straight to $\Delta X^D$ on L360, which is cleaner but hides the
  bookkeeping.
- **Switching-equation substitution as its own labeled frame** (CI-2 L694–710).
  Glasgow folds it silently into step 1.
- **$\mu_{d,\Delta}, \mu_{d,t}$ glossary block** (CI-2 L611–615) before the DR
  formula is used. Glasgow's L820–824 lists components but not the indexing
  convention.

## 5. Three concrete fixes (prioritized)

1. **Expand step 1 (L242–250) into 3–4 explicit rearrangement lines** mirroring
   CI-2 L684–688, with `\underbrace{}` labels on "split the difference,"
   "rearrange," and "switching equation." This is the highest-leverage fix
   because step 1 is the foundation the rest of the proof rests on.
2. **Split the DR-DiD frame (L811–826) into two frames** — one defining
   $p(X), \mu_{0,\Delta}(X), D/E[D]$, the Hájek-normalized IPW weight, and the
   indexing $\mu_{d,t} = E[Y_t \mid D{=}d, X]$; the next showing the assembled
   formula with the punchline "the reason you control for $X$ twice is because
   you don't know which model is right" lifted from CI-2 L629.
3. **Add an "add a zero" derivation slide somewhere in Lesson 2** that recreates
   01-Basics L541–554 — switching equation, add zero, ATT plus
   non-parallel-trends bias, all in red/blue with underbraces. This is Scott's
   most recognizable algebraic move and it is conspicuously absent from a deck
   that is otherwise faithful to his pacing.

**Files:** `/Users/scunning/the-remix-tour/glasgow/decks/covariates.tex`,
`/Users/scunning/Causal-Inference-2/Slides/Tex/02-Covariates.tex`,
`/Users/scunning/Causal-Inference-2/Slides/Tex/01-Basics.tex`.
