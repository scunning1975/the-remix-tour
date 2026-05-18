# Audit 3 — Development-Economics Framing of L7 (Compositional Change)

**Auditor:** Agent 3 of 3 (independent)
**Date:** 2026-05-12
**Scope:** L7 opening (covariates.tex lines ~1088-1242), Hong (2013) reading, Sant'Anna-Xu reading, audience composition.

---

## Verdict: **FAILS** the dev-econ test.

L7-F1 ("Two flavors of `X moves'") opens as a **method-taxonomy** slide. It tells students which estimator goes with which sampling design (panel vs. repeated cross-section). It does **not** tell a development economist *why this lesson is in their core toolkit*. The opening assumes the listener already accepts that repeated cross-sections are important; the dev-econ part of the audience needs that assumption converted into a hook. Crucially, the words "panels are expensive" or "household survey" or "LSMS/DHS" do not appear anywhere in the deck.

The L7-F5 slide ("When compositional change matters") does name surveys — but **only** CPS, NLSY, ACS (all US). It also arrives at the *end* of the section, after the dev economist has already decided whether to lean in or zone out. By that point the framing damage is done.

## Missing dev-econ contexts

1. **No mention of LSMS, DHS, MICS, IFLS, IHDS, ENaHO, ENIGH** — the canonical repeated-cross-section instruments dev economists actually run regressions on.
2. **No "panels are expensive" assertion.** The reason most applied work uses repeated cross-sections is never stated; the listener has to infer the motivation.
3. **Hong-as-canonical never connects to dev econ.** Hong's CEX example is presented as "internet diffusion in the US" rather than as "the prototype of a problem you have every time DHS reweights, every time LSMS adds a province, every time a sampling frame is refreshed."
4. **Sant'Anna-Xu's own dev-econ application is invisible.** Their empirical case is the South Africa-Mozambique trade corridor under SADC tariff reductions — a *developing-country* trade-and-corruption application using repeated cross-sections of shipment records. The deck never mentions this. This is the single highest-leverage missed asset in the section.
5. **Survey-design changes across rounds.** LSMS-2 vs LSMS-3, DHS standard recodes, expansion of frames after a census — these are the everyday dev-econ analog of Hong's "CEX expanded ~50% starting 1999" (noted in the reading). The deck does not bridge.

## Proposed new opening slide (insert **before** the current L7-F1)

```latex
%% ---------- L7-F0: why this lesson exists ----------
\begin{frame}{Most applied work doesn't have a panel}
\vspace{0.6em}
\pullquote{Panels are expensive. Repeated cross-sections are how a lot of applied work actually gets done.}{Anyone who's ever priced a long household-survey panel}
\vspace{0.8em}
\begin{itemize}
  \item \textbf{The US workhorses:} CPS, NLSY, ACS, CEX --- repeated cross-sections, not panels.
  \item \textbf{The development workhorses:} LSMS (World Bank), DHS (USAID), MICS (UNICEF), IFLS (Indonesia), IHDS (India) --- repeated rounds, mostly different households each wave.
  \item Same DiD recipe runs on all of them. \highlight{Same compositional-change problem too.}
\end{itemize}
\vspace{0.6em}
\begin{center}
\small\color{warmgray}\itshape
Hong (2013) found it in the CEX. Sant'Anna \& Xu's own application is shipments through the South Africa--Mozambique trade corridor.\\
The disease travels.
\end{center}
\end{frame}
```

## Rationale: why BEFORE L7-F1, not after

L7-F1 is a **taxonomy slide** — it answers "which estimator for which sampling design?" That is a *useful* slide, but it is a slide for someone who has already decided the lesson is worth their attention. The job of the opening is to *earn* that attention from a heterogeneous audience: half the room is thinking about US labor data, the other half is thinking about household surveys in low- and middle-income settings. Putting "Most applied work doesn't have a panel" first does three things L7-F1 cannot do: (1) it states the economic motivation (panels are costly, so we use rotating cross-sections), (2) it names the listener's actual dataset on screen so they see themselves in the problem, and (3) it pre-loads the Hong example with a dev-econ companion (Sant'Anna-Xu's SADC trade corridor) so when the canonical US example arrives in L7-F2, the dev economist already trusts that the machinery is for them too. Moving this content to *after* L7-F1 — or leaving it at L7-F5 — means the dev economist has spent four slides watching a method-taxonomy conversation before being told why they should care. By then half the room has decided this is the "US labor methods" lesson and quietly opened a browser tab.

**Word count: 489**
