#!/usr/bin/env python3
"""
build_dashboard_data.py — GTD dashboard data for "Prevention Without Proof".
Scans hypotheses/insights/decisions, maps the pipeline, embeds figures (PNG) WITH the
exact generating code (for flip-cards), reads the tables, and writes the walkable
courtroom checklist (ending in DDDiD -> synthetic control) + manuscript.
Run: python3 scripts/build_dashboard_data.py
"""
import json, csv, re
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).parent.parent
OUT = ROOT / "dashboard_data.json"

PIPELINE_SCRIPTS = [
    {"script":"code/python/eurostat_fetch.py","outputs":["data/raw/gdp_real_pc.json"],"level":1,"name":"Acquire Eurostat (cleaning)"},
    {"script":"code/python/build_panel.py","outputs":["data/clean/panel.csv"],"level":2,"name":"Build Eurostat panel 1994-2010"},
    {"script":"code/python/build_panel_extended.py","outputs":["data/clean/panel_extended.csv"],"level":2,"name":"Splice WHO pre-1994 -> extended panel 1986-2010"},
    {"script":"code/R/analysis.R","outputs":["output/estimates.json","output/tables/tab2_balance.csv"],"level":5,"name":"DiD diagnostics + balance + Bacon inputs"},
    {"script":"code/R/scm_all.R","outputs":["output/figures/fig_did_fails.png","output/figures/fig_scm_fit_IE.png","output/tables/tab_sdid_groups.csv"],"level":5,"name":"DiD-fails + augmented SCM (all 4) + synthetic DiD"},
    {"script":"code/R/bacon.R","outputs":["output/tables/tab_bacon.csv"],"level":5,"name":"Goodman-Bacon decomposition"},
    {"script":"code/python/replicate.py","outputs":["output/estimates_python.json"],"level":5,"name":"Python replication (differences)"},
    {"script":"code/stata/replicate.do","outputs":["code/stata/replicate.log"],"level":5,"name":"Stata replication (csdid)"},
]
A="code/R/analysis.R"; S="code/R/scm_all.R"; B="code/R/bacon.R"
FIGURE_SCRIPT_MAP={
 "fig_did_fails":S,"fig4_panelview":A,"fig5_cohort_counts":A,"fig6_outcome_by_cohort":A,
 "fig3_pscore_overlap":A,"fig8_event_study":A,"fig8c_calendar":A,"fig9_honestdid":A,
 "fig_robust_overlay":A,"fig_falsification_placebo":A,"fig_bacon":B,
}
for u in ("NO","SE","UK","IE"):
    for k in ("fit","gap","weights","spaghetti","rmspe"):
        FIGURE_SCRIPT_MAP[f"fig_scm_{k}_{u}"]=S
FIG_CAPTIONS={
 "fig_did_fails":"DiD fails: a +0.32/yr pre-trend runs unbroken through adoption",
 "fig4_panelview":"Staggered adoption (4 treated)","fig5_cohort_counts":"Cohort sizes",
 "fig6_outcome_by_cohort":"Suicide by cohort","fig3_pscore_overlap":"Propensity score separates",
 "fig8_event_study":"DiD event study (Eurostat panel)","fig8c_calendar":"Calendar-time ATT",
 "fig9_honestdid":"Rambachan-Roth sensitivity","fig_robust_overlay":"CS/BJS/SA agree on the naive number",
 "fig_falsification_placebo":"In-space placebo","fig_bacon":"Goodman-Bacon: TWFE not the culprit",
}
for u,nm in (("NO","Norway"),("SE","Sweden"),("UK","United Kingdom"),("IE","Ireland")):
    FIG_CAPTIONS[f"fig_scm_fit_{u}"]=f"{nm}: observed vs synthetic"
    FIG_CAPTIONS[f"fig_scm_gap_{u}"]=f"{nm}: gap event study"
    FIG_CAPTIONS[f"fig_scm_weights_{u}"]=f"{nm}: donor weights before/after ridge"
    FIG_CAPTIONS[f"fig_scm_spaghetti_{u}"]=f"{nm}: permutation spaghetti"
    FIG_CAPTIONS[f"fig_scm_rmspe_{u}"]=f"{nm}: post/pre RMSPE vs placebos"

def extract_code(stem, script_rel):
    """Find the ggsave(...stem...) call in the script and return the plot block above it."""
    p=ROOT/script_rel
    if not p.exists(): return ""
    lines=p.read_text().splitlines()
    idx=None
    # candidates: exact stem, and the sprintf prefix (stem minus a trailing _XX unit code)
    pref=re.sub(r'_[A-Z]{2}$','_',stem)
    for i,ln in enumerate(lines):
        if "ggsave" in ln and (stem in ln or (pref!=stem and pref in ln)): idx=i; break
    if idx is None:
        for i,ln in enumerate(lines):
            if stem in ln or (pref!=stem and pref in ln): idx=i; break
    if idx is None: return ""
    start=idx
    # walk up to the start of this plot block (blank line or a `pX<-ggplot`/`<-` assignment boundary)
    j=idx
    while j>0 and (idx-j)<22:
        if lines[j-1].strip()=="" : break
        j-=1
    return "\n".join(lines[j:idx+1]).strip()

def parse_frontmatter(fp):
    t=fp.read_text()
    if not t.startswith("---"): return {},t
    pp=t.split("---",2)
    if len(pp)<3: return {},t
    fm={}
    for line in pp[1].strip().split("\n"):
        if ":" in line:
            k,v=line.split(":",1); v=v.strip()
            if v.startswith("[") and v.endswith("]"): v=[x.strip().strip("'\"") for x in v[1:-1].split(",") if x.strip()]
            elif v.lower()=="null": v=None
            fm[k.strip()]=v
    return fm,pp[2].strip()
def get_mtime(p): return datetime.fromtimestamp(p.stat().st_mtime).strftime("%Y-%m-%d %H:%M") if p.exists() else None

def scan_hyp():
    out=[]
    for f in sorted((ROOT/"hypotheses").glob("H*.md")):
        fm,body=parse_frontmatter(f)
        if not fm.get("id"): continue
        claim=kills=""
        for s in body.split("##"):
            s=s.strip()
            if s.startswith("Claim"): claim=s.replace("Claim","").strip().split("\n")[0]
            elif s.startswith("Kills it"): kills=s.replace("Kills it","").strip().split("\n")[0]
        out.append({"id":fm["id"],"title":fm.get("title",""),"status":fm.get("status","conjecture"),
                    "parent":fm.get("parent") if fm.get("parent") not in ("null",None) else None,
                    "children":fm.get("children",[]),"claim":claim,"kills_it":kills,"file":str(f.relative_to(ROOT))})
    return out
def scan_insights():
    out=[]
    for f in sorted((ROOT/"insights").glob("2*.md")):
        fm,body=parse_frontmatter(f)
        if not fm.get("date"): continue
        finding=""
        for s in body.split("##"):
            if s.strip().startswith("Finding"): finding=s.strip().replace("Finding","").strip().split("\n")[0]
        out.append({"date":fm["date"],"title":fm.get("title",""),"updates":fm.get("updates",""),
                    "result":fm.get("result",""),"script":fm.get("script",""),"finding":finding,"file":str(f.relative_to(ROOT))})
    return sorted(out,key=lambda x:x["date"],reverse=True)
def scan_decisions():
    idx=ROOT/"decisions"/"INDEX.md"; out=[]
    if not idx.exists(): return out
    for line in idx.read_text().split("\n"):
        if line.startswith("|") and "---" not in line and "ID " not in line:
            c=[x.strip() for x in line.split("|")[1:-1]]
            if len(c)>=4: out.append({"id":c[0],"decision":c[1],"date":c[2],"rationale":c[3]})
    return out
def scan_pipeline():
    out=[]
    for e in PIPELINE_SCRIPTS:
        sp=ROOT/e["script"]; outs=[]; allf=True
        for o in e["outputs"]:
            op=ROOT/o; fresh=True
            if sp.exists() and op.exists(): fresh=op.stat().st_mtime>=sp.stat().st_mtime
            elif not op.exists(): fresh=False
            if not fresh: allf=False
            outs.append({"path":o,"exists":op.exists(),"mtime":get_mtime(op),"fresh":fresh})
        out.append({"script":e["script"],"name":e["name"],"level":e["level"],"exists":sp.exists(),
                    "script_mtime":get_mtime(sp),"outputs":outs,"all_fresh":allf})
    return out
def scan_figures():
    fd=ROOT/"output"/"figures"; out=[]
    for f in sorted(fd.glob("*.png")):
        stem=f.stem; sc=FIGURE_SCRIPT_MAP.get(stem); sp=ROOT/sc if sc else None
        fresh=(f.stat().st_mtime>=sp.stat().st_mtime) if (sp and sp.exists()) else None
        out.append({"name":stem,"path":str(f.relative_to(ROOT)),"mtime":get_mtime(f),
                    "caption":FIG_CAPTIONS.get(stem,""),"script":sc,"fresh":fresh,"orphaned":sc is None,
                    "code":extract_code(stem,sc) if sc else ""})
    return out
def read_csv_table(rel,caption):
    p=ROOT/rel
    if not p.exists(): return None
    rows=list(csv.reader(open(p)))
    if not rows: return None
    return {"name":Path(rel).stem,"caption":caption,"headers":rows[0],"rows":rows[1:]}
def scan_tables():
    specs=[("output/tables/tab2_balance.csv","Baseline balance (Imbens-Rubin; |d|>0.25 imbalanced) -> levels differ"),
           ("output/tables/tab_sdid_groups.csv","Synthetic DiD by adoption cohort (Arkhangelsky et al.)"),
           ("output/tables/tab_bacon.csv","Goodman-Bacon: TWFE is not the culprit"),
           ("output/tables/tab_scm_weights_IE.csv","Ireland donor weights: SCM vs ridge-augmented"),
           ("output/tables/tab_did_extrap.csv","DiD event study + pre-trend extrapolation")]
    return [t for t in (read_csv_table(r,c) for r,c in specs) if t]

def build_courtroom():
    sj=ROOT/"output/scm_results.json"; sc=json.loads(sj.read_text()) if sj.exists() else {}
    return {"stages":[
      {"id":1,"name":"Estimand & design: what DiD would require","status":"confirmed",
       "summary":"Target: ATT of adoption on suicide. DiD identifies it only under parallel trends -- an assumption about counterfactual trajectories the pre-period can speak to.",
       "evidence":["fig4_panelview.png","D07: group-weighted target"]},
      {"id":2,"name":"Check 1 -- levels: the groups are not comparable","status":"confirmed",
       "summary":"Every baseline covariate is imbalanced (Imbens-Rubin >0.25): adopters start with far lower suicide, higher unemployment, older populations.",
       "evidence":["tab2_balance.csv","fig3_pscore_overlap.png (propensity perfectly separates)"]},
      {"id":3,"name":"Check 2 -- trends: a pre-trend runs through adoption","status":"confirmed",
       "summary":f"A significant upward pre-trend (slope ~+0.32/yr, t~3.4) predates adoption and continues unbroken through it. The 'effect' is the extrapolated trend.",
       "evidence":["fig_did_fails.png","fig8_event_study.png"]},
      {"id":4,"name":"DDDiD -- do not difference; match on levels (Doudchenko-Imbens)","status":"confirmed",
       "summary":"With treated and controls differing in BOTH levels and trends, differencing extrapolates the gap rather than removing it. The checklist's terminal step: stop differencing, switch to synthetic control.",
       "evidence":["Doudchenko & Imbens (2016)","fig_bacon.png (TWFE is not the culprit -- the design is)"]},
      {"id":5,"name":"Synthetic control (all 4) + synthetic DiD: no detectable effect","status":"complicated",
       "summary":"Augmented SCM for each of the four adopters fits the pre-period well; post-gaps are small and wrong-signed; permutation p = 0.71/0.71/0.79/0.43. Synthetic DiD by cohort: +0.80/+1.24/+0.74, each < its s.e. No detectable effect, and no power to rule one out.",
       "evidence":["fig_scm_fit_IE.png","fig_scm_weights_IE.png","fig_scm_rmspe_IE.png","tab_sdid_groups.csv"]}]}

def build_manuscript():
    return {"earned":[
        "DiD is invalid here: adopters and never-adopters differ in levels (every covariate Imbens-Rubin imbalanced) AND trends (significant +0.32/yr pre-trend through adoption).",
        "Goodman-Bacon: TWFE (3.11) is not distorted by negative weighting (forbidden comparisons ~3%); the design is the problem, not the estimator.",
        "Augmented synthetic control for all four adopters fits the pre-period closely; ridge augmentation bias-corrects the donor weights (negative where raw fit is poor).",
        "Post-adoption gaps are small and wrong-signed; permutation p = 0.71 (NO), 0.71 (SE), 0.79 (UK), 0.43 (IE) -- all ordinary.",
        "Synthetic DiD by cohort: +0.80 (1995), +1.24 (2002), +0.74 (2005), each smaller than its standard error."],
      "thesis":"Difference-in-differences is the wrong tool here -- treated and control countries differ in levels and trends. Matching on the level path instead (augmented synthetic control for all four adopters, and synthetic DiD by cohort) finds no detectable effect of national suicide-prevention strategies on suicide, and no power to rule one out."}

if __name__=="__main__":
    hyp=scan_hyp(); ins=scan_insights(); dec=scan_decisions(); pipe=scan_pipeline()
    figs=scan_figures(); tabs=scan_tables(); court=build_courtroom(); manu=build_manuscript()
    counts={}
    for h in hyp: counts[h["status"]]=counts.get(h["status"],0)+1
    data={"summary":{"hypothesis_counts":counts,"total_hypotheses":len(hyp),"total_insights":len(ins),
                     "pipeline_stale":sum(1 for p in pipe if not p["all_fresh"]),"pipeline_total":len(pipe),
                     "generated_at":datetime.now().strftime("%Y-%m-%d %H:%M:%S")},
          "hypotheses":hyp,"insights":ins,"decisions":dec,"pipeline":pipe,"figures":figs,
          "tables":tabs,"courtroom":court,"manuscript":manu}
    OUT.write_text(json.dumps(data,indent=2,default=str))
    nc=sum(1 for f in figs if f["code"])
    print(f"hyp {len(hyp)} | insights {len(ins)} | decisions {len(dec)} | pipeline {len(pipe)} | figs {len(figs)} ({nc} with code) | tables {len(tabs)}")
    print(f"written {OUT}")
