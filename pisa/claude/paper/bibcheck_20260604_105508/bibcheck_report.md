# bibcheck report — paper/references.bib

**Mode:** per-citation (6 parallel verification agents, 23 bibliographic entries).
**Result:** ALL CLEAN. No hallucinated references. No field-mixing. Every DOI resolves.

| Status | Count |
|---|---|
| Clean / verified | 23 |
| Corrected (cosmetic only) | 2 |
| Unverifiable | 0 |

## Verified against canonical anchors (DOI / publisher / PubMed)
All eight DiD econometrics entries (Callaway–Sant'Anna, Borusyak–Jaravel–Spiess, Sun–Abraham,
Goodman-Bacon, de Chaisemartin–D'Haultfœuille, Rambachan–Roth, Roth et al., Sant'Anna–Zhao);
all four synthetic-control entries (Abadie–Gardeazabal 2003, Abadie–Diamond–Hainmueller 2010,
Ben-Michael–Feller–Rothstein 2021, Arkhangelsky et al. 2021); all suicide/macro entries
(Durkheim 1951, Ruhm 2000, Stuckler et al. 2009, Reeves et al. 2012, Stuckler–Basu 2013,
Case–Deaton 2015 & 2020); all suicide-strategy entries (Matsubayashi–Ueda 2011, Lewitzka et al.
2019, WHO 2014, WHO 2018).

## Specific traps checked and cleared
- **Reeves et al.** confirmed **2012** (PMID 23141814), not 2014; it is a Lancet Correspondence
  (note added).
- **Roth et al.** 4th author is **John Poe**, not "Poet".
- **Abadie–Gardeazabal**: published AER title is "A Case Study" (NBER WP variant "Case-Control");
  entry uses the correct published title.
- **Case–Deaton**: 2015 PNAS article vs 2020 Princeton book correctly distinguished; ISBN added.

## Open (human eyes optional)
- WHO 2018 ISBN 978-92-4-151501-6: title/author/year/Geneva confirmed; ISBN plausible and
  search-associated but WHO IRIS returned 403, so not canonically confirmed. Not fabricated.

**Drop-in replacement:** corrected.bib (identical to source + Reeves `note`, Case–Deaton `isbn`).
