"""
Build the EXTENDED, SPLICED country-year panel (1986-2010).

Suicide outcome = Eurostat age-standardised rate (1994-2010, European Standard
Population) with WHO Mortality Database rates (1986-1993, WHO World Standard
Population) chained on by a country-specific multiplicative factor estimated on
the 1994-2010 overlap. This puts the WHO pre-1994 values on the Eurostat scale.

The splice is a documented approximation: the two sources use different standard
populations. We chain multiplicatively because the Eurostat/WHO ratio is stable
within country across overlap years (agent-verified ~1.1-1.4).

Germany is dropped: WHO-MDB has no unified pre-1990 German series.
Output: data/clean/panel_extended.csv
"""
import csv, os, statistics as st
HERE=os.path.dirname(__file__); ROOT=os.path.abspath(os.path.join(HERE,"..",".."))
RAW=os.path.join(ROOT,"data","raw"); CLEAN=os.path.join(ROOT,"data","clean")
Y0,Y1=1986,2010

EU2ISO={"AT":"AUT","BE":"BEL","CH":"CHE","CZ":"CZE","DE":"DEU","EE":"EST","EL":"GRC",
 "ES":"ESP","HU":"HUN","IE":"IRL","IT":"ITA","LU":"LUX","NL":"NLD","NO":"NOR",
 "PT":"PRT","SE":"SWE","SI":"SVN","UK":"GBR"}
ISO2EU={v:k for k,v in EU2ISO.items()}

# WHO long series
who={}
for r in csv.DictReader(open(os.path.join(RAW,"who_mdb_suicide_agestd_18countries_long.csv"))):
    v=r["suicide_asdr_who"]
    if v not in ("","NA"): who[(r["iso3"],int(r["year"]))]=float(v)

# Eurostat panel (1994-2010): geo, year, suicide_sdr, gvar, status, country
euro={}; meta={}
for r in csv.DictReader(open(os.path.join(CLEAN,"panel.csv"))):
    g=r["geo"]; y=int(r["year"])
    if r["suicide_sdr"] not in ("","NA"): euro[(g,y)]=float(r["suicide_sdr"])
    meta[g]={"country":r["country"],"gvar":r["gvar"],"status":r["status"],"iso3":r["iso3"]}

geos=[g for g in meta if g in EU2ISO and g!="DE"]   # 18 WHO countries minus Germany (no pre-1990 WHO)

# splice factor per country: mean(Eurostat / WHO) over overlap years
factor={}
for g in geos:
    iso=EU2ISO[g]; ratios=[euro[(g,y)]/who[(iso,y)] for y in range(1994,Y1+1)
                           if (g,y) in euro and (iso,y) in who and who[(iso,y)]>0]
    if ratios: factor[g]=st.mean(ratios)

rows=[]
for g in sorted(geos):
    iso=EU2ISO[g]; m=meta[g]
    for y in range(Y0,Y1+1):
        if y>=1994 and (g,y) in euro:
            val=euro[(g,y)]; src="eurostat"
        elif y<1994 and (iso,y) in who and g in factor:
            val=who[(iso,y)]*factor[g]; src="who_spliced"
        elif y>=1994 and (iso,y) in who and g in factor:
            val=who[(iso,y)]*factor[g]; src="who_filled"  # Eurostat gap (e.g. IT 2004-05) filled by chained WHO
        else:
            val=None; src="missing"
        rows.append({"geo":g,"iso3":iso,"country":m["country"],"year":y,
                     "suicide":round(val,4) if val is not None else "",
                     "gvar":m["gvar"],"status":m["status"],"source":src})

cols=["geo","iso3","country","year","suicide","gvar","status","source"]
os.makedirs(CLEAN,exist_ok=True)
with open(os.path.join(CLEAN,"panel_extended.csv"),"w",newline="") as f:
    w=csv.DictWriter(f,fieldnames=cols); w.writeheader(); [w.writerow(r) for r in rows]

# report
print(f"panel_extended.csv: {len(rows)} rows, {len(geos)} countries, {Y0}-{Y1}")
print("\nsplice factors (Eurostat/WHO, mean over 1994-2010 overlap):")
for g in sorted(factor): print(f"  {g} {meta[g]['country'][:14]:14s} factor={factor[g]:.3f}")
print("\ncompleteness (non-missing suicide / 25 years):")
for g in sorted(geos):
    n=sum(1 for r in rows if r["geo"]==g and r["suicide"]!="")
    tr = "TREATED "+str(meta[g]["gvar"]) if meta[g]["status"]=="treated" else "control"
    print(f"  {g} {meta[g]['country'][:14]:14s} {tr:14s} {n}/25")
# sanity: Sweden spliced 1985-1994
print("\nSweden spliced suicide 1986-1996:")
for r in rows:
    if r["geo"]=="SE" and 1986<=r["year"]<=1996: print(f"  {r['year']} {r['suicide']} ({r['source']})")
