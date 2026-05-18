# Audit Summary — Assumption 5 & 6 PO Derivation
**Question:** Does the 9-slide rewrite of the PT-on-Y⁰ derivation succeed at (a) substance, (b) rhetoric of decks, (c) the connection to Post×X + id-FE?

## Three-auditor consensus

### ✅ Substance (math)
All three: **PASS.** Algebra verified step-by-step. Treated post/pre subtractions clean. α₂ cancellation in step 11 correct. The two cases (β=0 or ΔX^T=ΔX^C) follow.

### ⚠️ Rhetoric (titles, density, tempo)
**Three issues converged across agents:**
1. **Titles revert to labels.** Steps 1–4 use assertions ("the slopes look the same"). Steps 5–13 revert to stage directions ("take expectations: treated, post"). Voice breaks at step 5.
2. **Density spike at step 9.** The cancellation moment carries 2 stacked aligns + subtract directive + boxed result + definition footnote. Too much for the slide where students need the most space to read.
3. **Step 8's "α₂ switches off"** is described in a caption rather than visually greyed in place — color cue on step 9 works because the cancellation is rendered; step 8 doesn't get the same treatment.

### ❌ Connection to Post × X + id FE
**All three: missing or underweight.**
- Coda slide L2-F2o flags β_pre ≠ β_post in half a slide, says "we'll come back to it," and the deck never does.
- The lalonde.tex comparison table no longer has a Spec B ($1,559) row.
- CI-2 02-Covariates.tex never makes the additive-X-vs-Post×X distinction either.
- The $3,522-vs-$1,559 gap is exactly where the abstract proof would land on the LaLonde lab — and the connection isn't drawn.

## Recommendations to apply (in priority order)

1. **Expand coda** (L2-F2o, 1 slide → 4 slides) to link Spec A vs Spec B explicitly:
   - Same dataset, two specs, two answers
   - Spec A (additive X) → Assumption 5 & 6 → \$3,522
   - Spec B (id FE + Post×X) → different assumption → \$1,559
   - Two assumption sets, two answers
2. **Rewrite titles 6–12 as assertions.** Example: "Step 9 — the treated $Y^0$ trend collapses to $\alpha_2 + \beta\Delta X^T$"
3. **Split step 9** into two slides — cancellation needs breathing room.
4. **Visual grey on step 8** for α₂ position, not just caption.

## Status: actions in progress (auto-mode pass)

See audit_1.md, audit_2.md, audit_3.md for individual reports.
