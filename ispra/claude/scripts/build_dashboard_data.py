#!/usr/bin/env python3
"""
build_dashboard_data.py — GTD dashboard data for "Prevention Without Proof".
Scans hypotheses/insights/decisions, maps the pipeline, embeds figures (PNG),
reads the key tables, and writes the courtroom + manuscript views.
Run: python3 scripts/build_dashboard_data.py
"""
import json, csv
from pathlib import Path
from datetime import datetime

ROOT = Path(__file__).parent.parent
OUT = ROOT / "dashboard_data.json"

PIPELINE_SCRIPTS = [
    {"script":"code/python/eurostat_fetch.py","outputs":["data/raw/gdp_real_pc.json"],"level":1,"name":"Acquire Eurostat (cleaning)"},
    {"script":"code/python/build_panel.py","outputs":["data/clean/panel.csv"],"level":2,"name":"Build country-year panel (derived)"},
    {"script":"code/R/analysis.R","outputs":["output/estimates.json","output/figures/fig8_event_study.png","output/tables/tab2_balance.csv"],"level":5,"name":"CS DiD + event study + falsification"},
    {"script":"code/R/synth.R","outputs":["output/figures/fig_synth_fit_IE.png"],"level":5,"name":"Augmented synthetic control (UK, IE)"},
    {"script":"code/R/bacon.R","outputs":["output/tables/tab_bacon.csv","output/figures/fig_bacon.png"],"level":5,"name":"Goodman-Bacon decomposition"},
    {"script":"code/python/replicate.py","outputs":["output/estimates_python.json"],"level":5,"name":"Python replication (differences)"},
    {"script":"code/stata/replicate.do","outputs":["code/stata/replicate.log"],"level":5,"name":"Stata replication (csdid)"},
]
FIGURE_SCRIPT_MAP = {
    "fig4_panelview":"code/R/analysis.R","fig5_cohort_counts":"code/R/analysis.R",
    "fig6_outcome_by_cohort":"code/R/analysis.R","fig3_pscore_overlap":"code/R/analysis.R",
    "fig8_event_study":"code/R/analysis.R","fig8c_calendar":"code/R/analysis.R",
    "fig9_honestdid":"code/R/analysis.R","fig_robust_overlay":"code/R/analysis.R",
    "fig_falsification_placebo":"code/R/analysis.R","fig_bacon":"code/R/bacon.R",
    "fig_synth_fit_UK":"code/R/synth.R","fig_synth_fit_IE":"code/R/synth.R",
    "fig_synth_rmspe_UK":"code/R/synth.R","fig_synth_rmspe_IE":"code/R/synth.R",
    "fig_synth_gap_UK":"code/R/synth.R","fig_synth_gap_IE":"code/R/synth.R",
    "fig_synth_spaghetti_UK":"code/R/synth.R","fig_synth_spaghetti_IE":"code/R/synth.R",
}
FIG_CAPTIONS = {
    "fig4_panelview":"Staggered adoption (4 treated, 12 never-treated)",
    "fig5_cohort_counts":"Cohort composition — the design is thin",
    "fig6_outcome_by_cohort":"Suicide by cohort; all bend up in the recession",
    "fig3_pscore_overlap":"Propensity score perfectly separates -> regression adjustment",
    "fig8_event_study":"Event study (universal base): pre-trends flat, post positive",
    "fig8c_calendar":"Calendar-time ATT loads on 2008-2010",
    "fig9_honestdid":"Rambachan-Roth: effect cannot be signed",
    "fig_robust_overlay":"CS, BJS, Sun-Abraham agree (+2.7 to +3.2)",
    "fig_falsification_placebo":"In-space placebo: observed is ordinary (p=0.25)",
    "fig_bacon":"Goodman-Bacon: TWFE = weighted 2x2s; forbidden weight ~3%",
    "fig_synth_fit_IE":"Ireland: observed vs synthetic","fig_synth_rmspe_IE":"Ireland placebo RMSPE (p=0.69)",
    "fig_synth_fit_UK":"UK: observed vs synthetic","fig_synth_rmspe_UK":"UK placebo RMSPE (p=0.46)",
}

def parse_frontmatter(fp):
    t = fp.read_text();
    if not t.startswith("---"): return {}, t
    p = t.split("---",2)
    if len(p)<3: return {}, t
    fm={}
    for line in p[1].strip().split("\n"):
        if ":" in line:
            k,v=line.split(":",1); v=v.strip()
            if v.startswith("[") and v.endswith("]"): v=[x.strip().strip("'\"") for x in v[1:-1].split(",") if x.strip()]
            elif v.lower()=="null": v=None
            fm[k.strip()]=v
    return fm, p[2].strip()

def get_mtime(p): return datetime.fromtimestamp(p.stat().st_mtime).strftime("%Y-%m-%d %H:%M") if p.exists() else None

def scan_hyp():
    out=[];
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
                    "result":fm.get("result",""),"script":fm.get("script",""),"output":fm.get("output",""),
                    "finding":finding,"file":str(f.relative_to(ROOT))})
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
        fresh = (f.stat().st_mtime>=sp.stat().st_mtime) if (sp and sp.exists()) else None
        out.append({"name":stem,"path":str(f.relative_to(ROOT)),"mtime":get_mtime(f),
                    "caption":FIG_CAPTIONS.get(stem,""),"script":sc,"fresh":fresh,"orphaned":sc is None})
    return out

def read_csv_table(rel, caption):
    p=ROOT/rel
    if not p.exists(): return None
    rows=list(csv.reader(open(p)))
    if not rows: return None
    return {"name":Path(rel).stem,"caption":caption,"headers":rows[0],"rows":rows[1:]}

def scan_tables():
    specs=[("output/tables/tab2_balance.csv","Baseline balance (Imbens-Rubin std. diff; |d|>0.25 = imbalanced)"),
           ("output/tables/tab_bacon.csv","Goodman-Bacon decomposition of TWFE"),
           ("output/tables/tab5_cohort_counts.csv","Cohort composition"),
           ("output/tables/tab_referee_robustness.csv","Referee-requested robustness"),
           ("output/tables/tab_leaveoneout.csv","Leave-one-treated-country-out")]
    return [t for t in (read_csv_table(r,c) for r,c in specs) if t]

def build_courtroom():
    est=json.loads((ROOT/"output/estimates.json").read_text()) if (ROOT/"output/estimates.json").exists() else {}
    g=round(est.get("cs_group_att",0),2); ssz=round(est.get("pretrend_sumz2",0),1); pp=est.get("placebo_p",0)
    return {"stages":[
      {"id":1,"name":"Setup: real treatment, imbalanced covariate","status":"confirmed",
       "summary":"Staggered adoption is real (4 treated, 12 documented never-adopters). Unemployment is imbalanced (Imbens-Rubin std. diff 0.33).",
       "evidence":["fig4_panelview.png","tab2_balance.csv","D04: pscore separates -> regression adjustment"]},
      {"id":2,"name":"Event studies: pre-trends flat (long-difference base)","status":"confirmed",
       "summary":f"Under the universal g-1 baseline the pre-trend test does not reject (sum z^2 = {ssz}, df 8). The short-difference 'violation' (59.4) was an artifact.",
       "evidence":["fig8_event_study.png","D06: universal base period"]},
      {"id":3,"name":"Falsification: placebo finds nothing","status":"confirmed",
       "summary":f"In-space placebo p = {pp}; synthetic-control placebo p = 0.46 (UK), 0.69 (IE). The effect is indistinguishable from chance.",
       "evidence":["fig_falsification_placebo.png","fig_synth_rmspe_IE.png"]},
      {"id":4,"name":"Main result: positive but unsignable","status":"complicated",
       "summary":f"Group-weighted ATT = +{g}/100k (more suicide), robust across CS/BJS/SA — but Rambachan-Roth cannot sign it and it halves when post-communist controls are dropped.",
       "evidence":["fig_robust_overlay.png","fig9_honestdid.png","fig8c_calendar.png"]},
      {"id":5,"name":"Mechanism: selection + recession; TWFE not the culprit","status":"confirmed",
       "summary":"The positive sign reflects selection (adoption when suicide is high) and the 2008 recession. Goodman-Bacon: TWFE (3.11) ~ CS (2.7); forbidden comparisons carry ~3% weight.",
       "evidence":["fig_bacon.png","tab_bacon.csv"]}]}

def build_manuscript():
    return {"earned":[
        "Pre-trends are flat under the correct long-difference baseline (sum z^2 = 9.85, df 8).",
        "Unemployment is imbalanced (Imbens-Rubin 0.33), justifying conditional parallel trends.",
        "The naive staggered-DiD estimate is POSITIVE: +2.7/100k, agreed by CS, BJS, Sun-Abraham.",
        "Goodman-Bacon: TWFE reconstructs to 3.11; forbidden comparisons get ~3% weight.",
        "The estimate cannot be signed (Rambachan-Roth), is placebo-indistinguishable (p=0.25), and is fragile to the control pool."],
      "thesis":"The cross-national record cannot identify whether national suicide-prevention strategies reduced suicide. The positive association is selection plus the recession, not a measured effect — and that inseparability is the finding."}

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
    print(f"hyp {len(hyp)} | insights {len(ins)} | decisions {len(dec)} | pipeline {len(pipe)} | figs {len(figs)} | tables {len(tabs)}")
    print(f"written {OUT}")
