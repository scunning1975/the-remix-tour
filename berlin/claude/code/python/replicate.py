"""
Cross-language replication (PYTHON) of the R Callaway-Sant'Anna primary result.
Uses the `differences` package (ATTgt = Callaway & Sant'Anna 2021).
Verifies: N, group counts, outcome means, and the group-weighted / simple ATT.
"""
import json, os
import numpy as np, pandas as pd
from differences import ATTgt

ROOT = "/Users/scunning/the-remix-tour/ispra/claude"
d = pd.read_csv(os.path.join(ROOT, "data", "clean", "panel.csv"))

# ---- reproduce the R balanced sample exactly ----
span = list(range(int(d.year.min()), int(d.year.max())+1))
d0 = d[~d.geo.isin(["FI", "FR"])].copy()
ok = (d0.dropna(subset=["suicide_sdr","unemp"])
        .groupby("geo")["year"].apply(lambda s: set(span).issubset(set(s))))
keep = ok[ok].index.tolist()
m = d0[d0.geo.isin(keep) & d0.suicide_sdr.notna() & d0.unemp.notna()].copy()

print(f"PY balanced: {len(m)} obs, {m.geo.nunique()} countries, "
      f"{m.loc[m.gvar>0,'geo'].nunique()} treated: {sorted(m.loc[m.gvar>0,'geo'].unique())}")
print(f"PY suicide mean: overall={m.suicide_sdr.mean():.3f} "
      f"treated={m.loc[m.gvar>0,'suicide_sdr'].mean():.3f} "
      f"control={m.loc[m.gvar==0,'suicide_sdr'].mean():.3f}")

# differences expects MultiIndex (entity, time); cohort col with 0 = never treated
m["gvar"] = m["gvar"].astype(float)
m["gvar"] = np.where(m["gvar"]==0, np.nan, m["gvar"])
panel = m.set_index(["geo", "year"]).sort_index()

att = ATTgt(data=panel, cohort_name="gvar")
# regression adjustment, never-treated controls, conditioning on unemployment
att.fit(formula="suicide_sdr ~ unemp", control_group="never_treated",
        est_method="dr", n_jobs=1)

simple = att.aggregate("simple")
group  = att.aggregate("group")
event  = att.aggregate("event")

def grab(agg):
    # differences returns a DataFrame; ATT is the point estimate
    try:
        return float(np.atleast_1d(agg["ATT"].values)[0])
    except Exception:
        return float(np.atleast_1d(np.asarray(agg).ravel())[0])

out = {
    "n_obs": int(len(m)),
    "n_countries": int(m.geo.nunique()),
    "n_treated": int(m.loc[m.gvar>0,"geo"].nunique()),
    "mean_overall": float(m.suicide_sdr.mean()),
    "mean_treated": float(m.loc[m.gvar>0,"suicide_sdr"].mean()),
    "mean_control": float(m.loc[m.gvar==0,"suicide_sdr"].mean()),
    "py_simple_att": grab(simple),
    "py_group_att": grab(group),
}
print("\n=== PYTHON ATTgt aggregates ===")
print("simple:\n", simple)
print("group:\n", group)
print("event:\n", event)
with open(os.path.join(ROOT, "output", "estimates_python.json"), "w") as f:
    json.dump(out, f, indent=2)
print("\nWROTE estimates_python.json:", out)
