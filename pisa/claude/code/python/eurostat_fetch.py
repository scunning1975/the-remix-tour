"""
Eurostat JSON-stat fetcher + parser.
Pulls real data from the Eurostat dissemination API and flattens to long CSV.
All data are REAL. No simulation anywhere in this project.
"""
import json, urllib.request, urllib.parse, csv, os, sys, time

RAW = os.path.join(os.path.dirname(__file__), "..", "..", "data", "raw")
RAW = os.path.abspath(RAW)
BASE = "https://ec.europa.eu/eurostat/api/dissemination/statistics/1.0/data/"

def fetch(dataset, params, outfile, tries=3):
    q = urllib.parse.urlencode({**params, "format": "JSON"}, doseq=True)
    url = f"{BASE}{dataset}?{q}"
    for k in range(tries):
        try:
            with urllib.request.urlopen(url, timeout=120) as r:
                raw = r.read()
            d = json.loads(raw)
            if "error" in d:
                print(f"  API error for {dataset}: {d['error']}", file=sys.stderr)
                return None
            with open(os.path.join(RAW, outfile), "wb") as f:
                f.write(raw)
            return d
        except Exception as e:
            print(f"  attempt {k+1} failed for {dataset}: {e}", file=sys.stderr)
            time.sleep(2)
    return None

def flatten(d, value_name):
    """Flatten a JSON-stat dataset to rows keyed by geo+time (other dims assumed singleton)."""
    ids = d["id"]; size = d["size"]; dim = d["dimension"]
    strides = [1]*len(size)
    for i in range(len(size)-2, -1, -1):
        strides[i] = strides[i+1]*size[i+1]
    gi = ids.index("geo"); ti = ids.index("time")
    gidx = {v:k for k,v in dim["geo"]["category"]["index"].items()}
    glab = dim["geo"]["category"]["label"]
    tidx = {v:k for k,v in dim["time"]["category"]["index"].items()}
    rows = []
    for flat, val in d["value"].items():
        f = int(flat); rem = f; coord = []
        for s in strides:
            coord.append(rem//s); rem %= s
        gcode = gidx[coord[gi]]; yr = tidx[coord[ti]]
        rows.append((gcode, glab[gcode], yr, val))
    return rows

def write_long(rows, outcsv, value_name):
    with open(os.path.join(RAW, outcsv), "w", newline="") as f:
        w = csv.writer(f); w.writerow(["geo","country","year",value_name])
        for r in rows: w.writerow(r)
    yrs = sorted(set(r[2] for r in rows))
    geos = sorted(set(r[0] for r in rows))
    print(f"  -> {outcsv}: {len(rows)} obs, {len(geos)} geos, years {yrs[0]}..{yrs[-1]}")

PULLS = [
    # (dataset, params, outjson, outcsv, value_name)
    ("nama_10_pc",
     {"na_item":"B1GQ","unit":"CP_EUR_HAB"},
     "gdp_pc.json","gdp_pc.csv","gdp_pc_eur"),
    ("une_rt_a",
     {"sex":"T","age":"Y15-74","unit":"PC_ACT"},
     "unemp.json","unemp.csv","unemp_rate"),
    ("demo_pjanind",
     {"indic_de":"PC_Y65_MAX"},
     "share65.json","share65.csv","share_65plus"),
    ("demo_pjanind",
     {"indic_de":"MEDAGEPOP"},
     "medage.json","medage.csv","median_age"),
    ("demo_gind",
     {"indic_de":"AVG"},
     "pop_avg.json","pop_avg.csv","pop_avg"),
]

if __name__ == "__main__":
    for ds, params, oj, oc, vn in PULLS:
        print(f"Fetching {ds} {params} ...")
        d = fetch(ds, params, oj)
        if d is None:
            print(f"  SKIP {ds} (failed)"); continue
        rows = flatten(d, vn)
        write_long(rows, oc, vn)
    print("done.")
