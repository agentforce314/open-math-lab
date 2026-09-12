#!/usr/bin/env python3
"""Render docs/PROBLEM_INVENTORY_OVERVIEW.md + catalog/problems.json into a
self-contained HTML artifact (OPE-1). No external assets; safe to open offline.

Usage: python3 docs/tools/build_inventory_overview_html.py [out.html]
"""
import html
import json
import re
import sys
from collections import Counter
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CATALOG = ROOT / "catalog" / "problems.json"
OVERVIEW = ROOT / "docs" / "PROBLEM_INVENTORY_OVERVIEW.md"

# Full-statement (T2) rows: Lean proves the actual theorem, per ledger notes.
T2_IDS = {
    "ramsey-r33", "ramsey-r35", "ramsey-multicolor-r333", "schur-number",
    "weak-schur-ws2", "van-der-waerden-w23", "happy-ending-es3",
    "erdos-szekeres-monotone", "friendship-windmill", "euler-odd-distinct",
    "dirac-hamiltonian", "schur-partition-full", "schur-partition-full-glaisher",
    "erdos-woods",
}

# Statements for rows not described in the markdown tables.
EXTRA = {
    "demo-collatz-bound-toy": ("Toy bounded Collatz variant used only to exercise the pipeline.", "U"),
    "mathlib-gap-candidate": ("Placeholder seed; replaced by van-der-waerden-w23 / ramsey-r33 / schur-number.", "—"),
    "oeis-finite-check-candidate": ("Placeholder seed; replaced by ramsey-r33 + schur-number.", "—"),
    "sun-135": ("Sun 1-3-5 conjecture: every n ≥ 0 is x²+y²+z²+w² with x+3y+5z a square. Proved 2020 (Machiavelo–Tsopanidis); prize not live.", "G"),
    "derangement-formula": ("D(n) = n! Σ (−1)^k/k!; already Mathlib numDerangements.", "U"),
    "catalan-recurrence": ("C(n) = (1/(n+1))·C(2n,n) equals the recurrence definition; already in Mathlib.", "U"),
    "bertrand-postulate-computational": ("Certificate-style check of Bertrand's postulate to 10⁶; general theorem already in Mathlib.", "U"),
    "van-der-waerden-w24": ("W(2,4) = 35: any 2-colouring of {1..35} has a mono 4-term AP; 34 does not. Not one-wave.", "U/G"),
    "frobenius-coin-problem": ("Largest integer not representable as ax+by for coprime a,b is ab−a−b. Already Mathlib frobeniusNumber_pair.", "U"),
    "schur-partition": ("Schur 1926 identity, finite certificates n ≤ 24 (DP) / n ≤ 12 (Finset). The ∀n identity landed separately as schur-partition-full.", "G"),
    "graceful-tree-conjecture": ("All 560 non-isomorphic caterpillars with n ≤ 12 vertices admit graceful labelings (Python, 0 failures). Caterpillars known graceful ∀n (Rosa 1967).", "U/G"),
    "krenn-gu": ("Krenn–Gu conjecture: for even N ≥ 6 and D ≥ 3 colours, no edge-weighted K_N admits a perfectly monochromatic perfect-matching weight system in D colours (no linear-optics GHZ state without ancillas).", "R"),
    "hou-zeng-pfc": ("Hou–Zeng conjecture: every integer n > 4 is odd prime + positive Fibonacci + Catalan number (OEIS A154404).", "R"),
}

TIER_INFO = {
    "T0": ("Seed / demo", "Placeholder only; not a research bet."),
    "T1": ("Level A only", "Zero-sorry Lean for small witnesses / glue lemmas. The named theorem itself is NOT proved."),
    "T2": ("Full statement in Lean", "Zero-sorry Lean proof of the actual theorem. Still classical; no novelty."),
    "T3": ("Informal / heuristic", "Correct classical maths + compute artifacts; Lean absent, partial, or theorem already in Mathlib. Not a proof by lab rules."),
    "T4": ("Open — live cash", "Genuinely unsolved. Lab holds encoding + bounded evidence only. No claim."),
    "X": ("Out of scope / archived", "Rejected, superseded, or prize not live."),
}


def parse_statements(md: str):
    """Map problem id -> (statement, math level) from the markdown tables."""
    out = {}
    for line in md.splitlines():
        if not line.startswith("| `"):
            continue
        # split on unescaped pipes; `\|` is a literal pipe inside a cell
        cells = [c.strip().replace("\\|", "|") for c in re.split(r"(?<!\\)\|", line.strip().strip("|"))]
        if len(cells) < 2:
            continue
        ids = [i for i in re.findall(r"`([a-z0-9\-]+)`", cells[0]) if not i.startswith("-")]
        if not ids:
            continue
        stmt = cells[1]
        math = cells[2] if len(cells) > 2 and re.fullmatch(r"[UGR/ ]+", cells[2]) else ""
        # T3 table: (what was done, why not proof)
        if len(cells) >= 3 and not math and cells[0].startswith("`") and "What was done" not in cells[1]:
            stmt = f"{cells[1]} — {cells[2]}"
        # `schur-partition-full` / `-glaisher`
        if ids == ["schur-partition-full"] and "-glaisher" in cells[0]:
            ids.append("schur-partition-full-glaisher")
        for pid in ids:
            out.setdefault(pid, (strip_md(stmt), math))
    return out


def strip_md(s: str) -> str:
    s = re.sub(r"\*\*(.+?)\*\*", r"\1", s)
    s = re.sub(r"\*(.+?)\*", r"\1", s)
    s = s.replace("`", "")
    return s


def tier_of(p: dict) -> str:
    st, exp, pid = p.get("status"), p.get("expected"), p["id"]
    if st == "seed":
        return "T0"
    if st == "archived":
        return "X"
    if exp == "open":
        return "T4"
    if st == "formalized":
        return "T2" if pid in T2_IDS else "T1"
    return "T3"  # informal / heuristic / candidate / shortlisted


def dom(p):
    d = p.get("domain")
    d = ",".join(d) if isinstance(d, list) else str(d or "")
    return d.replace("_", " ")


def esc(s):
    return html.escape(str(s), quote=True)


def main(out_path: Path):
    cat = json.loads(CATALOG.read_text())
    md = OVERVIEW.read_text()
    stmts = parse_statements(md)
    problems = cat["problems"]

    rows = []
    for p in problems:
        pid = p["id"]
        stmt, math = stmts.get(pid, EXTRA.get(pid, ("(see catalog note)", "")))
        if not math:
            math = EXTRA.get(pid, ("", ""))[1]
        rows.append({
            "id": pid,
            "title": p.get("title", ""),
            "tier": tier_of(p),
            "status": p.get("status", ""),
            "expected": p.get("expected") or "—",
            "score": p.get("score"),
            "domain": dom(p),
            "math": math or "—",
            "statement": stmt,
            "lean": (p.get("lean_artifact") or "").replace("proofs/lean-project/", ""),
        })

    tier_order = ["T4", "T2", "T1", "T3", "T0", "X"]
    rows.sort(key=lambda r: (tier_order.index(r["tier"]), r["domain"], -(r["score"] or 0), r["id"]))
    tier_counts = Counter(r["tier"] for r in rows)
    status_counts = Counter(r["status"] for r in rows)
    expected_counts = Counter(r["expected"] for r in rows)

    def tr(r):
        score = "—" if r["score"] is None else r["score"]
        lean = f'<div class="lean">{esc(r["lean"])}</div>' if r["lean"] else ""
        return (
            f'<tr data-tier="{r["tier"]}" data-search="{esc((r["id"] + " " + r["title"] + " " + r["statement"] + " " + r["domain"]).lower())}">'
            f'<td><span class="tier {r["tier"]}">{r["tier"]}</span></td>'
            f'<td class="id"><code>{esc(r["id"])}</code><div class="title">{esc(r["title"])}</div>{lean}</td>'
            f'<td class="stmt">{esc(r["statement"])}</td>'
            f'<td class="c">{esc(r["math"])}</td>'
            f'<td class="c">{score}</td>'
            f'<td>{esc(r["domain"])}</td>'
            f'<td><span class="pill">{esc(r["status"])}</span><br><small>{esc(r["expected"])}</small></td>'
            "</tr>"
        )

    table_rows = "\n".join(tr(r) for r in rows)
    legend = "\n".join(
        f'<tr><td><span class="tier {t}">{t}</span></td><td><b>{esc(n)}</b></td><td>{esc(d)}</td><td class="c">{tier_counts.get(t, 0)}</td></tr>'
        for t, (n, d) in TIER_INFO.items()
    )
    chips = "".join(
        f'<button class="chip" data-filter="{t}">{t} <span>{tier_counts.get(t, 0)}</span></button>'
        for t in tier_order
    )
    status_tbl = "".join(f"<tr><td><code>{esc(k)}</code></td><td class='c'>{v}</td></tr>" for k, v in status_counts.most_common())
    expected_tbl = "".join(f"<tr><td><code>{esc(k)}</code></td><td class='c'>{v}</td></tr>" for k, v in expected_counts.most_common())

    open_rows = [r for r in rows if r["tier"] == "T4"]
    open_cards = ""
    open_detail = {
        "krenn-gu": ("€3,000 (Krenn / Leitner)",
                     "ProofLab/KrennGu.lean zero-sorry: EqSystem / pmSum encoding over ℤ, positive C₄ witness (D=2). Attack OPE-1038: exhaustive (8,3) and (6,3) searches over ring {−1,0,1} → 0 counterexample witnesses. Namesake ∀N,D not attempted."),
        "hou-zeng-pfc": ("$1,000 proof / $200 counterexample (Hou / Zeng)",
                         "ProofLab/HouZeng.lean zero-sorry: predicate IsOddPrimeFibCatalan, hou_zeng_five, bounded hou_zeng_le_N for 5 ≤ n ≤ 30 via native_decide. Already verified to 5·10¹³ by McNeil, so a counterexample is not a one-wave target."),
    }
    for r in open_rows:
        prize, held = open_detail.get(r["id"], ("", ""))
        open_cards += f"""
<div class="card">
  <div class="card-head"><code>{esc(r['id'])}</code> <span class="pill warn">open · score {r['score']}</span></div>
  <p class="stmt">{esc(r['statement'])}</p>
  <p><b>Prize:</b> {esc(prize)} — <b>do not claim.</b></p>
  <p><b>What the lab holds:</b> {esc(held)}</p>
</div>"""

    doc = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Open Math Lab — Problem Inventory Overview (OPE-1)</title>
<style>
  :root {{ --ink:#1b1f24; --muted:#5c6470; --line:#dfe3e8; --bg:#ffffff; --soft:#f5f7f9;
           --t0:#8a8f98; --t1:#3a7bd5; --t2:#1f8a4c; --t3:#b7791f; --t4:#c0392b; --tx:#6b6b6b; }}
  * {{ box-sizing:border-box; }}
  body {{ margin:0; font:15px/1.5 -apple-system, BlinkMacSystemFont, "Segoe UI", Helvetica, Arial, sans-serif; color:var(--ink); background:var(--bg); }}
  main {{ max-width:1180px; margin:0 auto; padding:32px 24px 64px; }}
  h1 {{ font-size:26px; margin:0 0 4px; }}
  h2 {{ font-size:19px; margin:36px 0 10px; padding-bottom:6px; border-bottom:1px solid var(--line); }}
  .meta {{ color:var(--muted); font-size:13px; }}
  table {{ border-collapse:collapse; width:100%; font-size:13.5px; }}
  th, td {{ text-align:left; vertical-align:top; padding:7px 9px; border-bottom:1px solid var(--line); }}
  th {{ background:var(--soft); font-weight:600; position:sticky; top:0; z-index:1; }}
  td.c, th.c {{ text-align:center; white-space:nowrap; }}
  td.id {{ min-width:190px; }}
  td.id .title {{ color:var(--muted); font-size:12px; }}
  td.id .lean {{ color:var(--muted); font-size:11.5px; font-family:ui-monospace, SFMono-Regular, Menlo, monospace; }}
  td.stmt {{ min-width:320px; }}
  code {{ font-family:ui-monospace, SFMono-Regular, Menlo, monospace; font-size:12.5px; background:var(--soft); padding:1px 4px; border-radius:3px; }}
  .tier {{ display:inline-block; min-width:30px; text-align:center; padding:1px 7px; border-radius:10px; color:#fff; font-size:12px; font-weight:600; }}
  .tier.T0 {{ background:var(--t0); }} .tier.T1 {{ background:var(--t1); }} .tier.T2 {{ background:var(--t2); }}
  .tier.T3 {{ background:var(--t3); }} .tier.T4 {{ background:var(--t4); }} .tier.X {{ background:var(--tx); }}
  .pill {{ display:inline-block; padding:0 7px; border-radius:9px; background:var(--soft); border:1px solid var(--line); font-size:12px; }}
  .pill.warn {{ background:#fdecea; border-color:#f5c2be; color:#8e2a20; }}
  .grid {{ display:grid; grid-template-columns:1fr 1fr; gap:20px; }}
  .box {{ border:1px solid var(--line); border-radius:8px; padding:14px 16px; background:var(--bg); }}
  .card {{ border:1px solid #f0c8c4; border-left:4px solid var(--t4); border-radius:8px; padding:12px 16px; margin:12px 0; background:#fffaf9; }}
  .card-head {{ font-size:15px; margin-bottom:6px; }}
  .callout {{ border-left:4px solid var(--t1); background:var(--soft); padding:12px 16px; border-radius:6px; margin:14px 0; }}
  .controls {{ display:flex; flex-wrap:wrap; gap:8px; align-items:center; margin:14px 0; }}
  .chip {{ border:1px solid var(--line); background:var(--bg); border-radius:16px; padding:4px 12px; cursor:pointer; font-size:13px; }}
  .chip.active {{ background:var(--ink); color:#fff; border-color:var(--ink); }}
  .chip span {{ opacity:.7; }}
  input[type=search] {{ flex:1; min-width:220px; padding:6px 10px; border:1px solid var(--line); border-radius:6px; font-size:14px; }}
  .count {{ color:var(--muted); font-size:13px; }}
  ol li, ul li {{ margin:4px 0; }}
  @media print {{ .controls {{ display:none; }} th {{ position:static; }} main {{ padding:0; }} }}
</style>
</head>
<body>
<main>
  <h1>Open Math Lab — Problem Inventory Overview</h1>
  <div class="meta">Issue OPE-1 · Research Director · snapshot 2026-09-12 · <code>catalog/problems.json</code> @ <code>b477799</code> · {len(rows)} entries · source doc <code>docs/PROBLEM_INVENTORY_OVERVIEW.md</code></div>

  <div class="callout">
    <b>Bottom line for the board.</b> {expected_counts.get('known-classical', 0)} of {len(rows)} entries are known-classical theorems used as Lean-formalization fuel.
    Exactly <b>{tier_counts.get('T4', 0)}</b> are genuinely open problems, and on both the lab holds only Level A encodings plus bounded negative searches — <b>no claim, no prize</b>.
    The catalog's <code>formalized</code> count ({status_counts.get('formalized', 0)}) overstates depth: {tier_counts.get('T1', 0)} of those rows are Level A witnesses whose named theorem is unproved; {tier_counts.get('T2', 0)} are full statements.
  </div>

  <h2>1. How to read difficulty</h2>
  <p>Two independent axes. Conflating them is how labs fool themselves.</p>
  <ul>
    <li><b>Math level</b> — how hard the mathematics is: <b>U</b> undergraduate / olympiad · <b>G</b> graduate / named theorem · <b>R</b> genuinely open research.</li>
    <li><b>Lab-status tier</b> — what is actually machine-checked in <code>proofs/lean-project/ProofLab/</code>:</li>
  </ul>
  <table>
    <thead><tr><th>Tier</th><th>Name</th><th>Meaning</th><th class="c">Count</th></tr></thead>
    <tbody>{legend}</tbody>
  </table>
  <p class="meta" style="margin-top:8px">Feasibility <b>score</b> (0–100) is the Scout rubric (<code>docs/FEASIBILITY_RUBRIC.md</code>): ≥80 prime, 60–79 feasible, 40–59 risky. It measures <i>attackability under lab constraints</i>, not depth — <code>taxicab-1729</code> at 86 means "trivially formalizable", not "important".</p>

  <div class="grid" style="margin-top:16px">
    <div class="box"><b>Catalog status</b><table><tbody>{status_tbl}</tbody></table></div>
    <div class="box"><b>Novelty tag (<code>expected</code>)</b><table><tbody>{expected_tbl}</tbody></table></div>
  </div>

  <h2>2. The genuinely open problems (T4 — research level)</h2>
  {open_cards}
  <p class="meta">Rejected as primes (OPE-1028): Millennium $1M (no sub-bounty lemma), Beal $1M (FLT-class), Erdős #78 constructive Ramsey (not finitely resolvable), RSA challenge (ended 2007), <code>sun-135</code> (proved 2020, archived).</p>

  <h2>3. All {len(rows)} problems</h2>
  <p>One-line statement of what each problem asks, the math level, the Scout score, and the lab tier. Sorted: open → full-statement → Level A → informal → seed → archived. Filter by tier or search.</p>
  <div class="controls">
    <button class="chip active" data-filter="ALL">All <span>{len(rows)}</span></button>{chips}
    <input type="search" id="q" placeholder="Search id, title, statement, domain…">
    <span class="count" id="count"></span>
  </div>
  <table id="tbl">
    <thead><tr><th>Tier</th><th>Problem</th><th>Statement</th><th class="c">Math</th><th class="c">Score</th><th>Domain</th><th>Status / novelty</th></tr></thead>
    <tbody>
{table_rows}
    </tbody>
  </table>

  <h2>4. Director's read</h2>
  <ol>
    <li><b>What we are good at:</b> landing small, zero-sorry Lean artifacts fast (~{status_counts.get('formalized', 0)} files, axiom-audited). The T2 rows — Ramsey numbers, Dirac, Schur ∀n, ES(3)=5 — are real Mathlib-gap contributions.</li>
    <li><b>What we are not doing:</b> solving open problems. The two open bets are correctly held at Level A with bounded negative searches; no prize is claimable and none will be claimed without the board.</li>
    <li><b>Portfolio risk:</b> the Level A mill (OPE-1062 → OPE-1449, ~40 waves) produces <code>formalized</code> rows whose named theorems are unproved. Honest per the notes, but the <i>count</i> overstates depth. Scout's OPE-1467 "honest none" is the right signal that the cheap-witness supply is exhausted.</li>
    <li><b>Recommended next direction (not actioned):</b> promote T1 rows to T2 (Level B namesake proofs — e.g. <code>ore-hamiltonian</code>, <code>konig-bipartite</code>, <code>erdos-ko-rado</code>) rather than opening more Level A slots. That is a Scout-shortlist decision, not a Director pick.</li>
  </ol>
  <p><b>Portfolio principle:</b> feasibility-first · reject crackpottery · Lean-gated claims · board is the only voice for external claims.</p>
  <p class="meta">Caveat: tier assignment was derived from catalog <code>status</code>/<code>expected</code> fields plus ledger notes; individual rows may be misclassified. <code>catalog/problems.json</code> and <code>docs/PROBLEM_LEDGER.md</code> remain the source of truth. No statuses were changed by this overview.</p>
</main>
<script>
(function() {{
  var rows = Array.prototype.slice.call(document.querySelectorAll('#tbl tbody tr'));
  var chips = Array.prototype.slice.call(document.querySelectorAll('.chip'));
  var q = document.getElementById('q'), count = document.getElementById('count');
  var tier = 'ALL';
  function apply() {{
    var s = q.value.trim().toLowerCase(), n = 0;
    rows.forEach(function(r) {{
      var ok = (tier === 'ALL' || r.dataset.tier === tier) && (!s || r.dataset.search.indexOf(s) !== -1);
      r.style.display = ok ? '' : 'none'; if (ok) n++;
    }});
    count.textContent = n + ' shown';
  }}
  chips.forEach(function(c) {{ c.addEventListener('click', function() {{
    chips.forEach(function(x) {{ x.classList.remove('active'); }}); c.classList.add('active');
    tier = c.dataset.filter; apply();
  }}); }});
  q.addEventListener('input', apply); apply();
}})();
</script>
</body>
</html>
"""
    out_path.write_text(doc)
    print(f"wrote {out_path} ({len(rows)} rows; tiers {dict(tier_counts)})")


if __name__ == "__main__":
    main(Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "docs" / "PROBLEM_INVENTORY_OVERVIEW.html")
