#!/usr/bin/env python3
"""
dashboard_server.py — Live research dashboard. Reads filesystem on every request.
No build step, no stale JSON. Always current.

Run: python3 dashboard_server.py
Open: http://localhost:8080/
"""

import http.server
import os
import re
import html as html_mod
from pathlib import Path
from datetime import datetime
from urllib.parse import urlparse, parse_qs

ROOT = Path(os.getcwd())
PORT = 8080

# =============================================================================
# FROZEN STRUCTURE
# =============================================================================

PIPELINE_SCRIPTS = [
    # Customize for your project. Each entry: script path, expected outputs, level (1-5), display name.
    # Example:
    # {"script": "scripts/python/00_clean.py", "outputs": ["data/clean/panel.csv"], "level": 1, "name": "Cleaning"},
    # {"script": "scripts/r/05_estimate.R", "outputs": ["output/figures/event_study.png"], "level": 5, "name": "Estimation"},
]

FIGURE_SCRIPT_MAP = {
    # Map figure stems (without extension) to their source pipeline script.
    # Example:
    # "event_study": "scripts/r/05_estimate.R",
    # "balance_plot": "scripts/python/04_figures.py",
}

COURTROOM_STAGES = [
    {"num": 1, "label": "Show Bite", "desc": "The event was real. Maps, volume, timeline.",
     "keywords": ["timeline", "geographic", "rollout", "event", "show bite"]},
    {"num": 2, "label": "Event Studies", "desc": "Dynamic effects. Pre-treatment coefficients = 0.",
     "keywords": ["event study", "pre-trend", "dynamic", "leads"]},
    {"num": 3, "label": "Falsification", "desc": "Placebo period must find nothing.",
     "keywords": ["falsification", "placebo", "null", "pre-period"]},
    {"num": 4, "label": "Main Results", "desc": "Headline ATT estimates.",
     "keywords": ["att", "main result", "headline", "estimate"]},
    {"num": 5, "label": "Mechanisms", "desc": "Heterogeneity, channels, floor hypothesis.",
     "keywords": ["mechanism", "heterogeneity", "channel", "subgroup"]},
]

CHECKLIST_STEPS = [
    # Customize for your project. Each step: num, name, description, expected output files.
    {"num": 1, "name": "Target parameter", "desc": "Define the estimand", "expected": []},
    {"num": 2, "name": "Treatment timing", "desc": "When and how units became treated", "expected": []},
    {"num": 3, "name": "Treatment rollout", "desc": "Geographic and temporal spread", "expected": []},
    {"num": 4, "name": "Outcomes by cohort", "desc": "Outcome trends by treatment group", "expected": []},
    {"num": 5, "name": "Covariate balance", "desc": "Treated vs. control observables", "expected": []},
    {"num": 6, "name": "Propensity / overlap", "desc": "Common support verification", "expected": []},
    {"num": 7, "name": "Estimate", "desc": "Primary ATT with confidence intervals", "expected": []},
    {"num": 8, "name": "Event study", "desc": "Dynamic treatment effects plot", "expected": []},
    {"num": 9, "name": "Sensitivity", "desc": "Robustness to parallel trends violations", "expected": []},
]

# =============================================================================
# SCANNING FUNCTIONS
# =============================================================================

def parse_frontmatter(filepath):
    text = filepath.read_text(encoding="utf-8")
    if not text.startswith("---"):
        return {}, text
    parts = text.split("---", 2)
    if len(parts) < 3:
        return {}, text
    fm = {}
    for line in parts[1].strip().split("\n"):
        if ":" in line:
            key, val = line.split(":", 1)
            val = val.strip()
            if val.startswith("[") and val.endswith("]"):
                val = [v.strip().strip("'\"") for v in val[1:-1].split(",") if v.strip()]
            elif val.lower() == "null":
                val = None
            elif val.lower() in ("true", "false"):
                val = val.lower() == "true"
            fm[key.strip()] = val
    return fm, parts[2].strip()


def scan_hypotheses():
    hyp_dir = ROOT / "hypotheses"
    if not hyp_dir.exists():
        return []
    results = []
    for f in sorted(hyp_dir.glob("H*.md")):
        fm, body = parse_frontmatter(f)
        if not fm.get("id"):
            continue
        claim, kills, evidence = "", "", []
        for section in body.split("##"):
            s = section.strip()
            if s.startswith("Claim"):
                claim = "\n".join(s.split("\n")[1:]).strip()
            elif s.startswith("Kills"):
                kills = "\n".join(s.split("\n")[1:]).strip()
            elif s.startswith("Evidence"):
                evidence = [l.strip() for l in s.split("\n")[1:] if l.strip().startswith("-")]
        results.append({
            "id": fm.get("id"), "title": fm.get("title", ""),
            "status": fm.get("status", "conjecture"), "parent": fm.get("parent"),
            "children": fm.get("children", []),
            "claim": claim, "kills_it": kills, "evidence": evidence,
            "body": body, "file": str(f.relative_to(ROOT)),
        })
    return results


def scan_insights():
    ins_dir = ROOT / "insights"
    if not ins_dir.exists():
        return []
    results = []
    for f in sorted(ins_dir.glob("2*.md")):
        fm, body = parse_frontmatter(f)
        if not fm.get("date"):
            continue
        finding = ""
        for section in body.split("##"):
            s = section.strip()
            if s.startswith("Finding"):
                finding = "\n".join(s.split("\n")[1:]).strip()
        results.append({
            "date": fm.get("date"), "title": fm.get("title", ""),
            "updates": fm.get("updates", ""), "result": fm.get("result", ""),
            "script": fm.get("script", ""), "output": fm.get("output", ""),
            "finding": finding, "file": str(f.relative_to(ROOT)),
        })
    return sorted(results, key=lambda x: x["date"], reverse=True)


def scan_decisions():
    idx = ROOT / "decisions" / "INDEX.md"
    if not idx.exists():
        return []
    results = []
    for line in idx.read_text().split("\n"):
        if line.startswith("|") and "---" not in line and "ID" not in line:
            cols = [c.strip() for c in line.split("|")[1:-1]]
            if len(cols) >= 4:
                results.append({"id": cols[0], "decision": cols[1], "date": cols[2], "rationale": cols[3]})
    return results


def scan_pipeline():
    results = []
    for entry in PIPELINE_SCRIPTS:
        sp = ROOT / entry["script"]
        sp_mtime = sp.stat().st_mtime if sp.exists() else 0
        outputs = []
        all_fresh = True
        for out in entry["outputs"]:
            op = ROOT / out
            if not op.exists():
                outputs.append({"path": out, "fresh": False, "status": "missing"})
                all_fresh = False
            elif op.stat().st_mtime >= sp_mtime:
                outputs.append({"path": out, "fresh": True, "status": "fresh"})
            else:
                outputs.append({"path": out, "fresh": False, "status": "stale"})
                all_fresh = False
        results.append({**entry, "exists": sp.exists(), "all_fresh": all_fresh, "outputs": outputs,
                        "mtime": datetime.fromtimestamp(sp_mtime).strftime("%Y-%m-%d %H:%M") if sp.exists() else None})
    return results


def scan_figures():
    fig_dir = ROOT / "output" / "figures"
    if not fig_dir.exists():
        return []
    results = []
    for f in sorted(fig_dir.glob("*.png")):
        stem = f.stem
        script = FIGURE_SCRIPT_MAP.get(stem)
        sp = ROOT / script if script and script != "ad-hoc" else None
        fresh = None
        if sp and sp.exists():
            fresh = f.stat().st_mtime >= sp.stat().st_mtime
        results.append({
            "name": stem, "path": str(f.relative_to(ROOT)),
            "mtime": datetime.fromtimestamp(f.stat().st_mtime).strftime("%Y-%m-%d %H:%M"),
            "script": script, "fresh": fresh, "orphaned": script is None,
        })
    return results


def scan_code_files():
    files = []
    for d in ["scripts/python", "scripts/r"]:
        p = ROOT / d
        if p.exists():
            for f in sorted(p.iterdir()):
                if f.suffix in (".py", ".R", ".r"):
                    files.append(str(f.relative_to(ROOT)))
    return files


DATA_CATALOG = [
    # Customize for your project. Each entry describes a raw data source.
    # Example:
    # {"name": "Survey Panel", "desc": "Longitudinal household survey, 2020-2025.",
    #  "paths": ["data/raw/survey_panel.csv"], "source": "Census Bureau",
    #  "collected": "2020-2025", "used_by_scripts": ["scripts/python/00_clean.py"]},
]


def scan_data():
    """Catalog raw data sources with auto-detected usage and previews."""
    results = []
    for entry in DATA_CATALOG:
        paths = entry["paths"]
        # Check existence — support glob patterns
        existing_files = []
        total_size = 0
        for p in paths:
            if "*" in p:
                existing_files.extend(ROOT.glob(p))
            else:
                fp = ROOT / p
                if fp.exists():
                    existing_files.append(fp)
        for fp in existing_files:
            total_size += fp.stat().st_size

        # Get a preview from the first CSV
        preview = None
        for fp in existing_files:
            if fp.suffix == ".csv" and fp.stat().st_size < 500_000_000:
                try:
                    with open(fp, "r", encoding="utf-8", errors="ignore") as fh:
                        lines = []
                        for i, line in enumerate(fh):
                            if i >= 4:
                                break
                            lines.append(line.rstrip())
                        preview = lines
                except Exception:
                    pass
                break

        # Trace to figures
        figures = []
        for script in entry["used_by_scripts"]:
            for fig_stem, fig_script in FIGURE_SCRIPT_MAP.items():
                if fig_script == script:
                    fig_path = f"output/figures/{fig_stem}.png"
                    if (ROOT / fig_path).exists():
                        figures.append(fig_path)

        size_str = f"{total_size/1024/1024:.0f} MB" if total_size > 1024*1024 else f"{total_size/1024:.0f} KB"
        results.append({
            "name": entry["name"],
            "desc": entry["desc"],
            "source": entry["source"],
            "collected": entry["collected"],
            "paths": paths,
            "n_files": len(existing_files),
            "exists": len(existing_files) > 0,
            "size": size_str if existing_files else None,
            "used_by": entry["used_by_scripts"],
            "figures": figures,
            "preview": preview,
        })
    return results


def map_insight_to_stage(insight):
    title_lower = insight["title"].lower()
    for stage in COURTROOM_STAGES:
        for kw in stage["keywords"]:
            if kw in title_lower:
                return stage["num"]
    return None


def mini_md(text):
    if not text:
        return ""
    text = html_mod.escape(text)
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'^# (.+)$', r'', text, flags=re.MULTILINE)
    text = re.sub(r'^## (.+)$', r'<h2>\1</h2>', text, flags=re.MULTILINE)
    text = re.sub(r'^### (.+)$', r'<h3>\1</h3>', text, flags=re.MULTILINE)
    text = re.sub(r'^- (.+)$', r'<li>\1</li>', text, flags=re.MULTILINE)
    text = re.sub(r'(<li>.*?</li>(\n|$))+', lambda m: '<ul>' + m.group(0) + '</ul>', text)
    text = text.replace("\n\n", "</p><p>").replace("\n", "<br>")
    return f"<p>{text}</p>"


# =============================================================================
# HTML RENDERING
# =============================================================================

def scan_audits():
    """Read audit records from audits/ directory."""
    audit_dir = ROOT / "audits"
    if not audit_dir.exists():
        return []
    results = []
    for f in sorted(audit_dir.glob("2*.md"), reverse=True):
        fm, body = parse_frontmatter(f)
        if not fm.get("date"):
            continue
        summary = ""
        for section in body.split("##"):
            s = section.strip()
            if s.startswith("Summary"):
                summary = "\n".join(s.split("\n")[1:]).strip()
        results.append({
            "date": fm.get("date"), "topic": fm.get("topic", ""),
            "conclusion": fm.get("conclusion", ""),
            "actions": fm.get("actions", ""),
            "narrative_updated": fm.get("narrative_updated", False),
            "summary": summary, "file": str(f.relative_to(ROOT)),
        })
    return results[:10]


def render_status(hypotheses, insights, pipeline):
    counts = {}
    for h in hypotheses:
        s = h["status"]
        counts[s] = counts.get(s, 0) + 1
    stale = sum(1 for p in pipeline if not p["all_fresh"])
    latest = insights[0] if insights else None
    audits = scan_audits()

    audits_html = ""
    if audits:
        audits_html = '<div class="card"><h3>Recent Audits</h3>'
        for a in audits[:5]:
            audits_html += f"""<div class="audit-card" onclick="this.querySelector('.audit-body').classList.toggle('open')">
              <div class="audit-header"><span class="audit-topic">{html_mod.escape(a['topic'])}</span><span class="date">{a['date']}</span></div>
              <div class="audit-conclusion">{html_mod.escape(a['conclusion'])}</div>
              <div class="audit-body"><p>{html_mod.escape(a['summary'][:300])}</p>{('<span class="badge confirmed">narrative updated</span>' if a['narrative_updated'] else '')}</div>
            </div>"""
        audits_html += '</div>'
    else:
        audits_html = '<div class="card"><h3>Recent Audits</h3><p class="empty">No audits yet. Run <code>/gtd audit [topic]</code> to start.</p></div>'

    return f"""
    <div class="status-grid">
      <div class="stat"><div class="stat-val">{len(hypotheses)}</div><div class="stat-lbl">Hypotheses</div></div>
      <div class="stat"><div class="stat-val green">{counts.get('confirmed',0)}</div><div class="stat-lbl">Confirmed</div></div>
      <div class="stat"><div class="stat-val yellow">{counts.get('testing',0)}</div><div class="stat-lbl">Testing</div></div>
      <div class="stat"><div class="stat-val red">{counts.get('complicated',0)}</div><div class="stat-lbl">Complicated</div></div>
      <div class="stat"><div class="stat-val">{len(pipeline)-stale}/{len(pipeline)}</div><div class="stat-lbl">Pipeline Fresh</div></div>
      <div class="stat"><div class="stat-val">{len(insights)}</div><div class="stat-lbl">Insights</div></div>
    </div>
    {'<div class="card"><h3>Latest Insight</h3><div class="insight-date">'+latest["date"]+'</div><strong>'+html_mod.escape(latest["title"])+'</strong> <span class="badge '+latest["result"]+'">'+latest["result"]+'</span><p class="finding">'+html_mod.escape(latest["finding"][:200])+'</p></div>' if latest else ''}
    {audits_html}
    """


def render_courtroom(insights, figures):
    staged = {s["num"]: [] for s in COURTROOM_STAGES}
    for ins in insights:
        snum = map_insight_to_stage(ins)
        if snum:
            staged[snum].append(ins)

    # Determine which hypotheses have complicated evidence in Stage 3 (falsification)
    falsification_compromised = set()
    for e in staged.get(3, []):
        if e["result"] == "complicated" and e.get("updates"):
            falsification_compromised.add(e["updates"])

    html = ""
    for stage in COURTROOM_STAGES:
        evidence = staged[stage["num"]]
        status = "done" if evidence else "todo"
        for e in evidence:
            if e["result"] == "complicated":
                status = "partial"
                break

        evidence_html = ""
        if evidence:
            for e in evidence:
                contested = ""
                if stage["num"] >= 4 and e.get("updates") in falsification_compromised and e["result"] != "complicated":
                    contested = ' <span class="badge-contested">contested by falsification</span>'
                evidence_html += f'<div class="court-evidence"><span class="badge {e["result"]}">{e["result"]}</span> {html_mod.escape(e["title"])}{contested} <span class="date">({e["date"]})</span></div>'
        else:
            evidence_html = '<div class="court-empty">No evidence filed yet</div>'

        html += f"""
        <div class="court-stage">
          <div class="court-num {status}">{stage['num']}</div>
          <div class="court-content">
            <div class="court-label">{stage['label']}</div>
            <div class="court-desc">{stage['desc']}</div>
            {evidence_html}
          </div>
        </div>"""
    return html


def render_checklist():
    html = ""
    for step in CHECKLIST_STEPS:
        if not step["expected"]:
            status = "pending"
        elif all((ROOT / e).exists() for e in step["expected"]):
            status = "done"
        elif any((ROOT / e).exists() for e in step["expected"]):
            status = "partial"
        else:
            status = "missing"
        html += f"""
        <div class="check-step">
          <div class="check-num {status}">{step['num']}</div>
          <div class="check-content">
            <div class="check-name">{step['name']}</div>
            <div class="check-desc">{step['desc']}</div>
            {''.join('<div class="check-file '+('exists' if (ROOT/e).exists() else 'missing')+'">'+e+'</div>' for e in step["expected"])}
          </div>
        </div>"""
    return html


def scan_stale_code():
    """Find scripts not in the pipeline DAG."""
    pipeline_paths = set(p["script"] for p in PIPELINE_SCRIPTS)
    stale = []
    for d in ["scripts/python", "scripts/r"]:
        p = ROOT / d
        if not p.exists():
            continue
        for f in sorted(p.iterdir()):
            if f.suffix not in (".py", ".R", ".r"):
                continue
            rel = str(f.relative_to(ROOT))
            if rel not in pipeline_paths:
                stat = f.stat()
                # Read first docstring/comment for description
                desc = ""
                try:
                    lines = f.read_text(encoding="utf-8", errors="ignore").split("\n")
                    for line in lines[1:20]:
                        l = line.strip().lstrip("#").lstrip("*").lstrip("\"").lstrip("'").strip()
                        if l and not l.startswith("!") and not l.startswith("import") and not l.startswith("library"):
                            desc = l[:120]
                            break
                except Exception:
                    pass
                stale.append({
                    "path": rel,
                    "name": f.name,
                    "created": datetime.fromtimestamp(stat.st_mtime).strftime("%Y-%m-%d"),
                    "size": f"{stat.st_size/1024:.0f} KB",
                    "desc": desc,
                })
    return stale


def render_pipeline(pipeline):
    levels = {1: "Cleaning", 2: "Derived", 4: "Figures", 5: "Estimation"}
    html = ""
    for lvl in sorted(set(p["level"] for p in pipeline)):
        html += f'<div class="pipe-level"><div class="pipe-level-hdr">Level {lvl}: {levels.get(lvl,"")}</div>'
        for p in pipeline:
            if p["level"] != lvl:
                continue
            status = "fresh" if p["all_fresh"] else "stale"
            html += f'<div class="pipe-item"><span class="pipe-script">{p["script"]}</span><span class="badge {status}">{status}</span></div>'
        html += '</div>'

    # Stale code section
    stale = scan_stale_code()
    if stale:
        html += f'<div class="stale-section"><h3>Stale Code <span style="color:var(--muted);font-weight:normal;font-size:0.75rem;">({len(stale)} scripts outside pipeline)</span></h3>'
        html += '<p style="color:var(--muted);font-size:0.72rem;margin-bottom:0.8rem;">Not in the pipeline DAG. Must be promoted via <code>/gtd audit</code> to appear in courtroom or checklist.</p>'
        for s in stale:
            html += f"""<div class="stale-item">
              <div class="stale-header"><span class="pipe-script">{s['name']}</span><span class="stale-date">{s['created']}</span></div>
              <div class="stale-path">{s['path']}</div>
              <div class="stale-desc">{html_mod.escape(s['desc'])}</div>
            </div>"""
        html += '</div>'

    return html


def render_hypotheses(hypotheses):
    html = ""
    parents = [h for h in hypotheses if not h["parent"]]
    for p in parents:
        html += f"""
        <div class="hyp-node {p['status']}">
          <div class="hyp-header"><span class="hyp-id">{p['id']}</span> {html_mod.escape(p['title'])} <span class="badge {p['status']}">{p['status']}</span></div>
          <div class="hyp-claim">{html_mod.escape(p['claim'][:200])}</div>
        </div>"""
        children = [h for h in hypotheses if h["parent"] == p["id"]]
        for c in children:
            html += f"""
            <div class="hyp-node child {c['status']}">
              <div class="hyp-header"><span class="hyp-id">{c['id']}</span> {html_mod.escape(c['title'])} <span class="badge {c['status']}">{c['status']}</span></div>
              <div class="hyp-claim">{html_mod.escape(c['claim'][:200])}</div>
            </div>"""
    return html


def render_insights(insights):
    html = '<table class="ins-table"><tr><th>Date</th><th>Finding</th><th>Hypothesis</th><th>Status</th></tr>'
    for ins in insights:
        html += f'<tr><td>{ins["date"]}</td><td>{html_mod.escape(ins["title"])}</td><td>{ins["updates"]}</td><td><span class="badge {ins["result"]}">{ins["result"]}</span></td></tr>'
    html += '</table>'
    return html


def render_decisions(decisions):
    html = '<table class="dec-table"><tr><th>ID</th><th>Decision</th><th>Date</th><th>Rationale</th></tr>'
    for d in decisions:
        html += f'<tr><td><strong>{d["id"]}</strong></td><td>{html_mod.escape(d["decision"])}</td><td>{d["date"]}</td><td>{html_mod.escape(d["rationale"])}</td></tr>'
    html += '</table>'
    return html


def render_figures(figures):
    html = '<div class="fig-grid">'
    for f in figures:
        if f["orphaned"]:
            border = "orphaned"
        elif f["fresh"]:
            border = "fresh"
        elif f["fresh"] is False:
            border = "stale"
        else:
            border = ""
        script_display = f['script'] or 'orphaned'
        html += f"""
        <div class="fig-flip-container" onclick="this.classList.toggle('flipped')">
          <div class="fig-flip-inner">
            <div class="fig-front fig-card {border}">
              <img src="/{f['path']}" loading="lazy">
              <div class="fig-name">{f['name']}</div>
              <div class="fig-meta">{f['mtime']} &middot; {script_display}</div>
            </div>
            <div class="fig-back fig-card {border}">
              <div class="fig-back-header">{f['name']}</div>
              <div class="fig-back-script">{script_display}</div>
              <div class="fig-back-action" onclick="event.stopPropagation();loadCode('{script_display}')">View full source &rarr;</div>
              <div class="fig-back-meta">
                <div>Modified: {f['mtime']}</div>
                <div>Status: {'fresh' if f['fresh'] else ('stale' if f['fresh'] is False else 'orphaned')}</div>
                <div>Path: {f['path']}</div>
              </div>
            </div>
          </div>
        </div>"""
    html += '</div>'
    return html


def render_data(data_entries):
    html = f'<p style="color:var(--muted);font-size:0.8rem;margin-bottom:1rem;">{len(data_entries)} source datasets cataloged.</p>'
    for d in data_entries:
        exists_cls = "fresh" if d["exists"] else "missing"
        exists_lbl = f'{d["n_files"]} files &middot; {d["size"]}' if d["exists"] else "NOT FOUND"
        scripts_html = " ".join(f'<span class="data-script">{s.split("/")[-1]}</span>' for s in d["used_by"]) if d["used_by"] else '<span style="color:var(--muted);font-size:0.7rem;">not yet in pipeline</span>'
        figs_html = ""
        if d.get("figures"):
            figs_html = '<div class="data-figs">Produces: ' + " ".join(f'<span class="data-fig">{Path(f).stem}</span>' for f in d["figures"]) + '</div>'
        preview_html = ""
        if d.get("preview"):
            preview_lines = "\n".join(html_mod.escape(l[:120]) for l in d["preview"])
            preview_html = f'<pre class="data-preview">{preview_lines}</pre>'
        html += f"""
        <div class="data-card">
          <div class="data-header">
            <span class="data-name">{html_mod.escape(d['name'])}</span>
            <span class="badge {exists_cls}">{exists_lbl}</span>
          </div>
          <div class="data-desc">{html_mod.escape(d['desc'])}</div>
          <div class="data-meta"><strong>Source:</strong> {html_mod.escape(d['source'])} &middot; <strong>Collected:</strong> {d['collected']}</div>
          <div class="data-used">Consumed by: {scripts_html}</div>
          {figs_html}
          {preview_html}
        </div>"""
    return html


def render_code(code_files):
    file_list = "".join(f'<div class="code-item" onclick="loadCode(\'{f}\')">{f.split("/")[-1]}</div>' for f in code_files)
    return f"""
    <div class="code-split">
      <div class="code-list">{file_list}</div>
      <div class="code-view"><div id="code-path"></div><pre id="code-body">Click a file to view</pre></div>
    </div>"""


def render_code_unified(pipeline, code_files):
    """Unified code view: Pipeline (green) + Stale (yellow) in left panel."""
    pipeline_paths = set(p["script"] for p in PIPELINE_SCRIPTS)
    stale_scripts = [f for f in code_files if f not in pipeline_paths]

    # Pipeline section
    pipe_items = ""
    for p in pipeline:
        status_cls = "fresh" if p["all_fresh"] else "stale"
        pipe_items += f'<div class="code-item pipe-{status_cls}" onclick="loadCode(\'{p["script"]}\')">{p["script"].split("/")[-1]} <span class="code-badge {status_cls}"></span></div>'

    # Stale section
    stale_items = ""
    for f in stale_scripts:
        stale_items += f'<div class="code-item stale-code" onclick="loadCode(\'{f}\')">{f.split("/")[-1]}</div>'

    return f"""
    <div class="code-split">
      <div class="code-list">
        <div class="code-section-hdr pipeline-hdr">Pipeline</div>
        {pipe_items}
        <div class="code-section-hdr stale-hdr">Stale</div>
        {stale_items}
      </div>
      <div class="code-view"><div id="code-path"></div><pre id="code-body">Click a file to view</pre></div>
    </div>"""


def render_tables():
    """Scan output/tables/ for .tex and .csv files."""
    tables_dir = ROOT / "output" / "tables"
    if not tables_dir.exists():
        return '<p class="empty">No output/tables/ directory.</p>'
    files = sorted(tables_dir.glob("*"))
    files = [f for f in files if f.suffix in (".tex", ".csv")]
    if not files:
        return '<p class="empty">No tables found.</p>'
    file_list = "".join(f'<div class="code-item" onclick="loadCode(\'{f.relative_to(ROOT)}\')">{f.name}</div>' for f in files)
    return f"""
    <div class="code-split">
      <div class="code-list">{file_list}</div>
      <div class="code-view"><div id="code-path"></div><pre id="code-body">Click a table file to view</pre></div>
    </div>"""


def annotate_hypothesis_ids(html_text, hypotheses):
    """Inject inline status badges next to hypothesis IDs in rendered HTML. Clickable to expand reason."""
    info_map = {}
    for h in hypotheses:
        reason = ""
        if h["status"] in ("complicated", "testing", "conjecture"):
            reason = h.get("kills_it", "") or h.get("claim", "")
            reason = reason.split("\n")[0][:150]
        info_map[h["id"]] = (h["status"], reason)

    for hid, (status, reason) in sorted(info_map.items(), key=lambda x: len(x[0]), reverse=True):
        if status in ("complicated", "testing") and reason:
            badge = f'<span class="narr-badge {status}" onclick="this.nextElementSibling.classList.toggle(\'open\')">{status}</span><span class="narr-reason">{html_mod.escape(reason)}</span>'
        else:
            badge = f'<span class="narr-badge {status}">{status}</span>'
        html_text = html_text.replace(f'{hid}', f'{hid} {badge}', 1)
    return html_text


def check_narrative_drift(content, hypotheses):
    """Check if narrative.md references hypotheses that are not confirmed."""
    status_map = {h["id"]: h["status"] for h in hypotheses}
    warnings = []
    for hid, status in status_map.items():
        if hid in content and status in ("complicated", "rejected", "testing"):
            warnings.append(f'{hid} is referenced but status is <span class="badge {status}">{status}</span>')
    return warnings


def render_narrative(hypotheses, insights):
    nf = ROOT / "narrative.md"
    # If narrative.md has real content (more than the placeholder), use it
    if nf.exists():
        content = nf.read_text().strip()
        if len(content) > 100 and not content.startswith("# Narrative\n\nThe narrative will be assembled"):
            drift_warnings = check_narrative_drift(content, hypotheses)
            warning_html = ""
            if drift_warnings:
                items = "".join(f'<li>{w}</li>' for w in drift_warnings)
                warning_html = f'<div class="narr-warning"><strong>Drift detected:</strong> narrative references unconfirmed material.<ul>{items}</ul></div>'
            rendered = mini_md(content)
            rendered = annotate_hypothesis_ids(rendered, hypotheses)
            return f'{warning_html}<div class="narrative-prose">{rendered}</div>'

    # Auto-assemble from confirmed/complicated material — present tense, current state only
    sections = []

    # What do we currently believe?
    confirmed = [h for h in hypotheses if h["status"] == "confirmed"]
    complicated = [h for h in hypotheses if h["status"] == "complicated"]
    testing = [h for h in hypotheses if h["status"] == "testing"]

    if confirmed:
        items = "".join(f'<li><strong>{h["id"]}:</strong> {html_mod.escape(h["claim"][:150])}</li>' for h in confirmed)
        sections.append(f'<div class="narr-section"><h3>What We Know</h3><ul>{items}</ul></div>')

    if complicated:
        items = "".join(f'<li><strong>{h["id"]}:</strong> {html_mod.escape(h["claim"][:150])}</li>' for h in complicated)
        sections.append(f'<div class="narr-section"><h3>What Is Complicated</h3><ul>{items}</ul></div>')

    if testing:
        items = "".join(f'<li><strong>{h["id"]}:</strong> {html_mod.escape(h["claim"][:150])}</li>' for h in testing)
        sections.append(f'<div class="narr-section"><h3>What We Are Testing</h3><ul>{items}</ul></div>')

    # Latest confirmed insights as supporting evidence
    confirmed_insights = [i for i in insights if i["result"] == "confirmed"][:5]
    if confirmed_insights:
        items = "".join(f'<li><span class="date">{i["date"]}</span> {html_mod.escape(i["title"])}</li>' for i in confirmed_insights)
        sections.append(f'<div class="narr-section"><h3>Supporting Evidence</h3><ul>{items}</ul></div>')

    if not sections:
        return '<p class="empty">No confirmed material yet. The narrative emerges as courtroom stages are completed.</p>'

    return '<div class="narrative-auto">' + "".join(sections) + '<p style="color:var(--muted);font-size:0.7rem;margin-top:1.5rem;">Auto-assembled from confirmed material. Write narrative.md to replace with authored prose.</p></div>'


def render_skills():
    """Scan ~/.claude/skills/ for installed skills and render them."""
    skills_dir = Path.home() / ".claude" / "skills"
    if not skills_dir.exists():
        return '<p class="empty">No skills directory found.</p>'
    skills = []
    for d in sorted(skills_dir.iterdir()):
        if not d.is_dir():
            continue
        skill_file = d / "SKILL.md"
        if not skill_file.exists():
            continue
        fm, body = parse_frontmatter(skill_file)
        name = fm.get("name", d.name)
        desc = fm.get("description", "")
        # Extract argument hint if present
        hint = fm.get("argument-hint", "")
        if isinstance(hint, list):
            hint = " ".join(hint)
        skills.append({"name": name, "desc": desc, "hint": hint})

    html = ""
    for s in skills:
        html += f"""<div class="skill-card">
          <div class="skill-name">/{s['name']} <span class="skill-hint">{html_mod.escape(s['hint'])}</span></div>
          <div class="skill-desc">{html_mod.escape(s['desc'][:200])}</div>
        </div>"""
    return html


def render_manuscript():
    mf = ROOT / "manuscript_outline.md"
    if mf.exists():
        return mini_md(mf.read_text())
    return '<p class="empty">No manuscript_outline.md found.</p>'


# =============================================================================
# PAGE ASSEMBLY
# =============================================================================

CSS = """
:root { --bg:#0f1115; --surface:#1a1d23; --surface2:#22262e; --surface3:#2a2f38; --border:#333940;
  --text:#e8ecf0; --muted:#8892a0; --accent:#8b5cf6; --green:#34d399; --yellow:#fbbf24; --red:#f87171;
  --green-dim:rgba(52,211,153,0.12); --yellow-dim:rgba(251,191,36,0.12); --red-dim:rgba(248,113,113,0.12); }
* { margin:0; padding:0; box-sizing:border-box; }
body { font-family:'Inter',-apple-system,sans-serif; background:var(--bg); color:var(--text); display:flex; min-height:100vh; font-size:14px; line-height:1.6; }
nav { width:200px; background:var(--surface); border-right:1px solid var(--border); padding:1rem 0; flex-shrink:0; position:sticky; top:0; height:100vh; overflow-y:auto; }
nav .title { padding:0.8rem 1rem; font-weight:700; font-size:1rem; color:var(--accent); }
nav .group { padding:0.5rem 1rem 0.2rem; font-size:0.65rem; text-transform:uppercase; letter-spacing:0.08em; color:var(--muted); margin-top:0.5rem; }
nav .btn { display:block; width:100%; text-align:left; padding:0.4rem 1rem; font-size:0.8rem; color:var(--muted); background:none; border:none; cursor:pointer; border-left:3px solid transparent; }
nav .btn:hover { color:var(--text); background:var(--surface2); }
nav .btn.active { color:var(--accent); border-left-color:var(--accent); background:var(--surface2); }
main { flex:1; padding:2rem; max-width:1100px; }
.view { display:none; } .view.active { display:block; }
h2 { font-size:1.2rem; margin-bottom:1rem; font-weight:600; }
.card { background:var(--surface); border:1px solid var(--border); border-radius:8px; padding:1.2rem; margin-bottom:1rem; }
.status-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(130px,1fr)); gap:0.8rem; margin-bottom:1.5rem; }
.stat { background:var(--surface); border:1px solid var(--border); border-radius:6px; padding:0.8rem 1rem; text-align:center; }
.stat-val { font-size:1.4rem; font-weight:700; } .stat-lbl { font-size:0.7rem; color:var(--muted); text-transform:uppercase; letter-spacing:0.04em; }
.stat-val.green { color:var(--green); } .stat-val.yellow { color:var(--yellow); } .stat-val.red { color:var(--red); }
.badge { display:inline-block; padding:0.15rem 0.5rem; border-radius:10px; font-size:0.65rem; font-weight:600; text-transform:uppercase; }
.badge.confirmed { background:var(--green-dim); color:var(--green); } .badge.testing { background:var(--yellow-dim); color:var(--yellow); }
.badge.complicated { background:var(--red-dim); color:var(--red); } .badge.fresh { background:var(--green-dim); color:var(--green); }
.badge.stale { background:var(--yellow-dim); color:var(--yellow); } .badge.missing { background:var(--red-dim); color:var(--red); }
.badge.done { background:var(--green-dim); color:var(--green); } .badge.partial { background:var(--yellow-dim); color:var(--yellow); }
.badge.todo { background:var(--surface2); color:var(--muted); } .badge.pending { background:var(--surface2); color:var(--muted); }
.court-stage { display:flex; gap:0.8rem; padding:0.8rem; background:var(--surface); border:1px solid var(--border); border-radius:6px; margin-bottom:0.6rem; }
.court-num { width:28px; height:28px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.7rem; font-weight:700; flex-shrink:0; }
.court-num.done { background:var(--green-dim); color:var(--green); } .court-num.partial { background:var(--yellow-dim); color:var(--yellow); } .court-num.todo { background:var(--surface2); color:var(--muted); }
.court-label { font-weight:600; font-size:0.85rem; } .court-desc { font-size:0.75rem; color:var(--muted); }
.court-evidence { font-size:0.78rem; margin-top:0.3rem; padding:0.2rem 0; border-top:1px solid var(--border); }
.court-empty { font-size:0.72rem; color:var(--muted); font-style:italic; margin-top:0.3rem; }
.check-step { display:flex; gap:0.8rem; padding:0.7rem; background:var(--surface); border:1px solid var(--border); border-radius:6px; margin-bottom:0.5rem; align-items:center; }
.check-num { width:26px; height:26px; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.7rem; font-weight:700; flex-shrink:0; }
.check-num.done { background:var(--green-dim); color:var(--green); } .check-num.partial { background:var(--yellow-dim); color:var(--yellow); }
.check-num.missing { background:var(--red-dim); color:var(--red); } .check-num.pending { background:var(--surface2); color:var(--muted); }
.check-name { font-weight:600; font-size:0.82rem; } .check-desc { font-size:0.72rem; color:var(--muted); }
.check-file { font-size:0.65rem; font-family:'SF Mono',monospace; color:var(--muted); } .check-file.exists { color:var(--green); } .check-file.missing { color:var(--red); }
.pipe-level { margin-bottom:1rem; } .pipe-level-hdr { font-size:0.7rem; text-transform:uppercase; letter-spacing:0.05em; color:var(--muted); padding:0.3rem 0.5rem; background:var(--surface2); border-radius:4px 4px 0 0; }
.pipe-item { display:flex; justify-content:space-between; align-items:center; padding:0.5rem 0.8rem; border:1px solid var(--border); border-top:none; font-size:0.8rem; }
.pipe-script { font-family:'SF Mono',monospace; font-size:0.75rem; }
.stale-section { margin-top:2rem; padding-top:1.5rem; border-top:1px solid var(--border); }
.stale-section h3 { font-size:0.9rem; margin-bottom:0.5rem; }
.stale-item { padding:0.6rem 0.8rem; border:1px solid var(--border); border-left:3px solid var(--yellow); border-radius:0 4px 4px 0; margin-bottom:0.5rem; background:var(--surface); }
.stale-header { display:flex; justify-content:space-between; align-items:center; }
.stale-date { font-size:0.7rem; color:var(--muted); }
.stale-path { font-size:0.65rem; color:var(--muted); font-family:'SF Mono',monospace; }
.stale-desc { font-size:0.72rem; color:var(--text); margin-top:0.2rem; }
.hyp-node { padding:0.8rem 1rem; border-left:3px solid var(--border); margin-bottom:0.5rem; background:var(--surface); border-radius:0 6px 6px 0; }
.hyp-node.confirmed { border-left-color:var(--green); } .hyp-node.testing { border-left-color:var(--yellow); } .hyp-node.complicated { border-left-color:var(--red); }
.hyp-node.child { margin-left:1.5rem; } .hyp-id { font-family:'SF Mono',monospace; color:var(--accent); font-size:0.8rem; margin-right:0.4rem; }
.hyp-header { font-size:0.85rem; } .hyp-claim { font-size:0.75rem; color:var(--muted); margin-top:0.3rem; }
table { width:100%; border-collapse:collapse; font-size:0.8rem; } th { text-align:left; padding:0.5rem; border-bottom:1px solid var(--border); color:var(--muted); font-size:0.7rem; text-transform:uppercase; }
td { padding:0.5rem; border-bottom:1px solid var(--border); }
.fig-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(280px,1fr)); gap:1rem; }
.fig-flip-container { perspective:1000px; cursor:pointer; }
.fig-flip-inner { position:relative; transition:transform 0.5s; transform-style:preserve-3d; }
.fig-flip-container.flipped .fig-flip-inner { transform:rotateY(180deg); }
.fig-front, .fig-back { backface-visibility:hidden; }
.fig-back { position:absolute; top:0; left:0; width:100%; height:100%; transform:rotateY(180deg); overflow-y:auto; padding:1rem; }
.fig-back-header { font-weight:600; font-size:0.85rem; margin-bottom:0.5rem; }
.fig-back-script { font-family:'SF Mono',monospace; font-size:0.75rem; color:var(--accent); margin-bottom:0.5rem; }
.fig-back-action { font-size:0.75rem; color:var(--green); cursor:pointer; margin-bottom:0.8rem; }
.fig-back-action:hover { text-decoration:underline; }
.fig-back-meta { font-size:0.7rem; color:var(--muted); line-height:1.6; }
.fig-card { background:var(--surface); border:1px solid var(--border); border-radius:6px; overflow:hidden; }
.fig-card.fresh { border-color:var(--green); } .fig-card.stale { border-color:var(--yellow); } .fig-card.orphaned { border-color:var(--muted); }
.fig-card img { width:100%; height:auto; display:block; }
.fig-name { padding:0.4rem 0.6rem; font-size:0.75rem; font-weight:600; } .fig-meta { padding:0 0.6rem 0.4rem; font-size:0.65rem; color:var(--muted); }
.data-card { background:var(--surface); border:1px solid var(--border); border-radius:6px; padding:1rem; margin-bottom:0.8rem; }
.data-header { display:flex; justify-content:space-between; align-items:center; }
.data-name { font-weight:600; font-size:0.85rem; font-family:'SF Mono',monospace; }
.data-desc { font-size:0.78rem; color:var(--text); margin-top:0.4rem; line-height:1.5; }
.data-meta { font-size:0.7rem; color:var(--muted); margin-top:0.3rem; }
.data-used { font-size:0.72rem; color:var(--muted); margin-top:0.4rem; }
.data-script { background:var(--surface2); padding:0.1rem 0.4rem; border-radius:3px; font-family:'SF Mono',monospace; font-size:0.65rem; margin-right:0.3rem; }
.data-figs { font-size:0.72rem; color:var(--muted); margin-top:0.3rem; }
.data-fig { background:var(--accent);background:rgba(139,92,246,0.15); color:var(--accent); padding:0.1rem 0.4rem; border-radius:3px; font-size:0.65rem; margin-right:0.3rem; }
.data-preview { background:var(--surface2); border:1px solid var(--border); border-radius:4px; padding:0.5rem 0.7rem; margin-top:0.5rem; font-family:'SF Mono',monospace; font-size:0.65rem; line-height:1.5; overflow-x:auto; color:var(--muted); max-height:6rem; overflow-y:auto; }
.code-split { display:flex; height:70vh; border:1px solid var(--border); border-radius:6px; overflow:hidden; }
.code-list { width:220px; overflow-y:auto; background:var(--surface); border-right:1px solid var(--border); }
.code-item { padding:0.4rem 0.8rem; font-size:0.75rem; font-family:'SF Mono',monospace; cursor:pointer; color:var(--muted); display:flex; justify-content:space-between; align-items:center; } .code-item:hover { background:var(--surface2); color:var(--text); }
.code-section-hdr { padding:0.4rem 0.8rem; font-size:0.65rem; text-transform:uppercase; letter-spacing:0.06em; font-weight:600; }
.pipeline-hdr { color:var(--green); border-bottom:1px solid var(--border); }
.stale-hdr { color:var(--yellow); border-top:1px solid var(--border); border-bottom:1px solid var(--border); margin-top:0.5rem; }
.code-badge { width:8px; height:8px; border-radius:50%; display:inline-block; }
.code-badge.fresh { background:var(--green); } .code-badge.stale { background:var(--yellow); }
.code-item.stale-code { border-left:2px solid var(--yellow); }
.code-view { flex:1; overflow:auto; padding:1rem; background:var(--surface2); }
#code-path { font-size:0.7rem; color:var(--accent); margin-bottom:0.5rem; font-family:'SF Mono',monospace; }
#code-body { font-family:'SF Mono','Fira Code',monospace; font-size:0.72rem; line-height:1.8; white-space:pre; }
.insight-date { font-size:0.7rem; color:var(--muted); } .finding { font-size:0.8rem; color:var(--muted); margin-top:0.4rem; }
.date { font-size:0.7rem; color:var(--muted); }
.empty { color:var(--muted); font-style:italic; }
.narr-section { margin-bottom:1.5rem; } .narr-section h3 { font-size:0.95rem; margin-bottom:0.5rem; color:var(--accent); }
.narr-section ul { list-style:none; padding:0; } .narr-section li { padding:0.4rem 0; border-bottom:1px solid var(--border); font-size:0.82rem; line-height:1.5; }
.narrative-auto { max-width:700px; }
.narr-warning { background:rgba(248,113,113,0.1); border:1px solid var(--red); border-radius:6px; padding:0.8rem 1rem; margin-bottom:1.5rem; font-size:0.8rem; }
.narr-warning strong { color:var(--red); }
.narr-warning ul { margin-top:0.4rem; padding-left:1rem; }
.narr-warning li { font-size:0.75rem; margin:0.2rem 0; }
.narr-badge { display:inline-block; padding:0.1rem 0.4rem; border-radius:8px; font-size:0.6rem; font-weight:600; text-transform:uppercase; vertical-align:middle; margin-left:0.2rem; }
.narr-badge.confirmed { background:var(--green-dim); color:var(--green); }
.narr-badge.testing { background:var(--yellow-dim); color:var(--yellow); cursor:pointer; }
.narr-badge.complicated { background:var(--red-dim); color:var(--red); cursor:pointer; }
.narr-badge.conjecture { background:var(--surface2); color:var(--muted); }
.narr-reason { display:none; font-size:0.72rem; color:var(--red); font-style:italic; background:var(--surface2); padding:0.3rem 0.6rem; border-radius:4px; margin-left:0.3rem; }
.narr-reason.open { display:inline; }
.badge-contested { background:rgba(248,113,113,0.15); color:var(--red); font-size:0.6rem; padding:0.1rem 0.4rem; border-radius:8px; font-weight:500; margin-left:0.3rem; }
.narrative-prose { max-width:700px; font-size:0.85rem; line-height:1.8; }
.narrative-prose h2 { font-size:1rem; margin-top:2.5rem; margin-bottom:0.8rem; color:var(--accent); padding-top:1.5rem; border-top:1px solid var(--border); }
.narrative-prose h2:first-child { margin-top:0; padding-top:0; border-top:none; }
.narrative-prose h3 { font-size:0.9rem; margin-top:1.5rem; margin-bottom:0.5rem; color:var(--text); }
.narrative-prose p { margin-bottom:1rem; }
.narrative-prose strong { color:var(--text); }
.audit-card { padding:0.7rem; border:1px solid var(--border); border-radius:6px; margin-bottom:0.6rem; cursor:pointer; transition:background 0.1s; }
.audit-card:hover { background:var(--surface2); }
.audit-header { display:flex; justify-content:space-between; align-items:center; }
.audit-topic { font-weight:600; font-size:0.82rem; }
.audit-conclusion { font-size:0.75rem; color:var(--muted); margin-top:0.2rem; }
.audit-body { display:none; margin-top:0.5rem; padding-top:0.5rem; border-top:1px solid var(--border); font-size:0.75rem; color:var(--text); line-height:1.5; }
.audit-body.open { display:block; }
.skill-card { padding:0.7rem 1rem; border:1px solid var(--border); border-radius:6px; margin-bottom:0.5rem; background:var(--surface); }
.skill-name { font-family:'SF Mono',monospace; font-size:0.85rem; font-weight:600; color:var(--accent); }
.skill-hint { font-weight:normal; color:var(--muted); font-size:0.7rem; }
.skill-desc { font-size:0.75rem; color:var(--text); margin-top:0.2rem; line-height:1.4; }
"""

JS = """
function show(id) {
  document.querySelectorAll('.view').forEach(v => v.classList.remove('active'));
  document.querySelectorAll('nav .btn').forEach(b => b.classList.remove('active'));
  document.getElementById('v-'+id).classList.add('active');
  document.querySelector('[data-tab="'+id+'"]').classList.add('active');
}
async function loadCode(path) {
  document.getElementById('code-path').textContent = path;
  try {
    const r = await fetch('/api/code?path='+encodeURIComponent(path));
    if (!r.ok) throw new Error('HTTP '+r.status);
    const text = await r.text();
    document.getElementById('code-body').textContent = text;
  } catch(e) {
    document.getElementById('code-body').textContent = 'Error: '+e.message;
  }
  show('code');
}
"""


def build_page(hypotheses, insights, decisions, pipeline, figures, code_files, data_entries):
    tabs = [
        ("narrative", "Narrative"),
        ("overview", "Overview"),
        ("courtroom", "Courtroom"),
        ("checklist", "Checklist"),
        ("code", "Code"),
        ("data", "Data"),
        ("hypotheses", "Hypotheses"),
        ("insights", "Insights"),
        ("decisions", "Decisions"),
        ("figures", "Figures"),
        ("tables", "Tables"),
        ("skills", "Skills"),
    ]
    nav_groups = {"narrative": "Output", "courtroom": "Structure", "hypotheses": "Evidence", "skills": "Reference"}
    nav_html = '<div class="title">Research Dashboard</div>'
    for tab_id, tab_label in tabs:
        if tab_id in nav_groups and nav_groups[tab_id] is not None:
            nav_html += f'<div class="group">{nav_groups[tab_id]}</div>'
        active = " active" if tab_id == "narrative" else ""
        nav_html += f'<button class="btn{active}" data-tab="{tab_id}" onclick="show(\'{tab_id}\')">{tab_label}</button>'

    views = f"""
    <div class="view active" id="v-narrative"><h2>Narrative</h2><p style="color:var(--muted);font-size:0.78rem;margin-bottom:1rem;">The current best understanding. Always present-tense. Updates in place as evidence accumulates.</p>{render_narrative(hypotheses, insights)}</div>
    <div class="view" id="v-overview"><h2>Overview</h2>{render_status(hypotheses, insights, pipeline)}</div>
    <div class="view" id="v-courtroom"><h2>The Courtroom</h2><p style="color:var(--muted);font-size:0.78rem;margin-bottom:1rem;">Five stages. A claim is earned only when all stages are confirmed.</p>{render_courtroom(insights, figures)}</div>
    <div class="view" id="v-checklist"><h2>DiD Checklist</h2><p style="color:var(--muted);font-size:0.78rem;margin-bottom:1rem;">Nine mechanical steps. Green = output exists. Red = missing.</p>{render_checklist()}</div>
    <div class="view" id="v-code"><h2>Code</h2>{render_code_unified(pipeline, code_files)}</div>
    <div class="view" id="v-data"><h2>Data</h2>{render_data(data_entries)}</div>
    <div class="view" id="v-hypotheses"><h2>Hypothesis DAG</h2><p style="color:var(--muted);font-size:0.78rem;margin-bottom:1rem;">Audit trail. Every path taken, including dead ends.</p>{render_hypotheses(hypotheses)}</div>
    <div class="view" id="v-insights"><h2>Insights</h2>{render_insights(insights)}</div>
    <div class="view" id="v-decisions"><h2>Binding Decisions</h2>{render_decisions(decisions)}</div>
    <div class="view" id="v-figures"><h2>Figures</h2>{render_figures(figures)}</div>
    <div class="view" id="v-tables"><h2>Tables</h2><p style="color:var(--muted);font-size:0.78rem;margin-bottom:1rem;">LaTeX table sources from <code>output/tables/</code>. Click to view.</p>{render_tables()}</div>
    <div class="view" id="v-skills"><h2>Skills</h2><p style="color:var(--muted);font-size:0.78rem;margin-bottom:1rem;">Invoke with <code>/skill_name</code> in Claude Code.</p>{render_skills()}</div>
    """

    return f"""<!DOCTYPE html><html><head><meta charset="utf-8"><title>Research Dashboard</title>
    <style>{CSS}</style></head><body>
    <nav>{nav_html}</nav><main>{views}</main>
    <script>{JS}</script></body></html>"""


# =============================================================================
# SERVER
# =============================================================================

class DashboardHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path in ("/", "/dashboard"):
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.end_headers()
            hypotheses = scan_hypotheses()
            insights = scan_insights()
            decisions = scan_decisions()
            pipeline = scan_pipeline()
            figures = scan_figures()
            code_files = scan_code_files()
            data_entries = scan_data()
            page = build_page(hypotheses, insights, decisions, pipeline, figures, code_files, data_entries)
            self.wfile.write(page.encode())
        elif parsed.path == "/api/code":
            qs = parse_qs(parsed.query)
            path = qs.get("path", [""])[0]
            fp = ROOT / path
            if fp.exists() and fp.is_file() and not ".." in path:
                self.send_response(200)
                self.send_header("Content-Type", "text/plain; charset=utf-8")
                self.end_headers()
                self.wfile.write(fp.read_bytes())
            else:
                self.send_error(404, f"Not found: {path}")
        else:
            super().do_GET()

    def log_message(self, format, *args):
        pass


if __name__ == "__main__":
    os.chdir(ROOT)
    server = http.server.HTTPServer(("", PORT), DashboardHandler)
    print(f"Dashboard live at http://localhost:{PORT}/")
    print(f"Reading from: {ROOT}")
    print("Press Ctrl+C to stop.")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nStopped.")
