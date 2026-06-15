"""
Build the clean country x year analysis panel (1994-2010) from REAL Eurostat + World Bank
raw files. No simulation. Every variable traceable to a raw source file.

Output: data/clean/panel.csv
"""
import json, csv, os

HERE = os.path.dirname(__file__)
RAW = os.path.abspath(os.path.join(HERE, "..", "..", "data", "raw"))
CLEAN = os.path.abspath(os.path.join(HERE, "..", "..", "data", "clean"))
os.makedirs(CLEAN, exist_ok=True)

Y0, Y1 = 1994, 2010

# Eurostat 2-letter -> ISO3 (for World Bank merge)
EU2ISO = {
 "AT":"AUT","BE":"BEL","BG":"BGR","CH":"CHE","CY":"CYP","CZ":"CZE","DE":"DEU",
 "DK":"DNK","EE":"EST","EL":"GRC","ES":"ESP","FI":"FIN","FR":"FRA","HR":"HRV",
 "HU":"HUN","IE":"IRL","IS":"ISL","IT":"ITA","LT":"LTU","LU":"LUX","LV":"LVA",
 "MT":"MLT","NL":"NLD","NO":"NOR","PL":"POL","PT":"PRT","RO":"ROU","SE":"SWE",
 "SI":"SVN","SK":"SVK","UK":"GBR",
}

def read_eurostat_json(fn, value_name, geo_filter=None):
    d = json.load(open(os.path.join(RAW, fn)))
    ids = d["id"]; size = d["size"]; dim = d["dimension"]
    strides = [1]*len(size)
    for i in range(len(size)-2, -1, -1):
        strides[i] = strides[i+1]*size[i+1]
    gi = ids.index("geo"); ti = ids.index("time")
    gidx = {v:k for k,v in dim["geo"]["category"]["index"].items()}
    tidx = {v:k for k,v in dim["time"]["category"]["index"].items()}
    out = {}
    for flat, val in d["value"].items():
        f = int(flat); rem = f; coord = []
        for s in strides:
            coord.append(rem//s); rem %= s
        g = gidx[coord[gi]]; yr = int(tidx[coord[ti]])
        if geo_filter and g not in geo_filter: continue
        out[(g, yr)] = val
    return out

def read_csv_long(fn, key_geo, val_idx, val_name):
    out = {}
    with open(os.path.join(RAW, fn)) as f:
        r = csv.reader(f); header = next(r)
        for row in r:
            out[(row[0], int(row[2]))] = float(row[val_idx]) if row[val_idx] not in ("",) else None
    return out

# --- treatment table ---
treat = {}
with open(os.path.join(RAW, "treatment_dates.csv")) as f:
    for row in csv.DictReader(f):
        treat[row["geo"]] = row

geos = set(treat.keys())

# --- outcome: suicide SDR (Eurostat JSON) ---
suicide = read_eurostat_json("suicide_country_9410.json", "suicide_sdr", geo_filter=geos)
# --- real GDP per capita ---
gdp = read_eurostat_json("gdp_real_pc.json", "gdp_real_pc", geo_filter=geos)
# --- share 65+ ---
share65 = read_eurostat_json("share65.json", "share65", geo_filter=geos)
# --- median age ---
medage = read_eurostat_json("medage.json", "medage", geo_filter=geos)
# --- population (avg) ---
pop = read_eurostat_json("pop_avg.json", "pop", geo_filter=geos)

# --- World Bank unemployment (ISO3) ---
wb_unemp = {}
with open(os.path.join(RAW, "wb_unemp.csv")) as f:
    for row in csv.DictReader(f):
        wb_unemp[(row["iso3"], int(row["year"]))] = float(row["unemp_rate"])

rows = []
for g in sorted(geos):
    iso = EU2ISO.get(g, g)
    tr = treat[g]
    status = tr["status"]
    ay = tr["adoption_year"]
    gvar = int(ay) if ay not in ("NA","") and status=="treated" else 0  # CS 'first treated period'; 0 = never
    for yr in range(Y0, Y1+1):
        rows.append({
            "geo": g, "iso3": iso, "country": tr["country"], "year": yr,
            "suicide_sdr": suicide.get((g,yr)),
            "gdp_real_pc": gdp.get((g,yr)),
            "unemp": wb_unemp.get((iso,yr)),
            "share65": share65.get((g,yr)),
            "medage": medage.get((g,yr)),
            "pop": pop.get((g,yr)),
            "status": status,
            "adoption_year": ay,
            "gvar": gvar,
        })

cols = ["geo","iso3","country","year","suicide_sdr","gdp_real_pc","unemp",
        "share65","medage","pop","status","adoption_year","gvar"]
with open(os.path.join(CLEAN, "panel.csv"), "w", newline="") as f:
    w = csv.DictWriter(f, fieldnames=cols); w.writeheader()
    for r in rows: w.writerow(r)

# coverage report
print(f"panel.csv written: {len(rows)} rows, {len(geos)} countries, {Y0}-{Y1}")
def cov(var):
    n = sum(1 for r in rows if r[var] not in (None,""))
    return n
for v in ["suicide_sdr","gdp_real_pc","unemp","share65","medage","pop"]:
    print(f"  {v}: {cov(v)}/{len(rows)} non-missing")

# per-country completeness on the core analysis vars
print("\nPer-country non-missing (suicide, gdp, unemp) out of 17 years:")
core = ["suicide_sdr","gdp_real_pc","unemp"]
for g in sorted(geos):
    sub = [r for r in rows if r["geo"]==g]
    comp = sum(1 for r in sub if all(r[c] not in (None,"") for c in core))
    print(f"  {g} {treat[g]['country'][:18]:18s} {treat[g]['status'][:12]:12s} adopt={treat[g]['adoption_year']:>4} complete={comp}/17")
