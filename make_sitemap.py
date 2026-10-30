"""Run:  python make_sitemap.py
Reads data.js and writes sitemap.xml (all exam / subject / topic / syllabus / PYQ pages).
Run it again every time you add an exam, subject or topic, then commit sitemap.xml."""
import json, datetime
from xml.sax.saxutils import escape

BASE = "https://emerging-sciences.github.io/emergingsciences.github.io/"   # change only if your site address changes

src = open("data.js", encoding="utf-8").read()
start = src.index("window.ES_DATA = ") + len("window.ES_DATA = ")
D = json.loads(src[start:src.rindex("};") + 1])

subs = {s["id"]: s for s in D["subjects"]}
urls = []                                   # (path, priority)
def add(path, pr="0.6"):
    if path not in [u[0] for u in urls]:
        urls.append((path, pr))

for p, pr in [("index.html", "1.0"), ("lectures.html", "0.9"), ("material.html", "0.9"),
              ("mock.html", "0.9"), ("support.html", "0.3")]:
    add(p, pr)

for ex in D["exams"]:
    e = ex["id"]
    papers = ex.get("papers") or [None]
    for page in ("lectures", "material", "mock"):
        add(f"{page}.html?e={e}", "0.8")
        for p in (ex.get("papers") or []):
            add(f"{page}.html?e={e}&p={p}", "0.7")
    for p in papers:
        q = f"&p={p}" if p else ""
        add(f"material.html?e={e}{q}&s=syllabus", "0.8")
        add(f"material.html?e={e}{q}&s=pyqs", "0.8")
    for sid in ex.get("subjects", []):          # topics that actually have lectures
        s = subs.get(sid)
        if s and s.get("live"):
            add(f"lectures.html?e={e}&s={sid}", "0.7")
            add(f"material.html?e={e}&s={sid}", "0.6")

today = datetime.date.today().isoformat()
out = ['<?xml version="1.0" encoding="UTF-8"?>',
       '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
for path, pr in urls:
    out.append(f"  <url><loc>{escape(BASE + path)}</loc><lastmod>{today}</lastmod><priority>{pr}</priority></url>")
out.append("</urlset>")
open("sitemap.xml", "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"sitemap.xml written with {len(urls)} URLs")
