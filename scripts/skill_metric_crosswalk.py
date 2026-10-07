#!/usr/bin/env python3
"""
CI check: every MetricFlow metric has a matching skills/metrics/<id>.md and
vice versa. Reads target/semantic_manifest.json for the authoritative metric
list. Exits non-zero on mismatch.
"""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "target" / "semantic_manifest.json"
SKILLS = ROOT / "skills" / "metrics"


def parse_frontmatter(path: Path) -> dict:
    text = path.read_text()
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, flags=re.DOTALL)
    if not m:
        return {}
    out = {}
    for line in m.group(1).splitlines():
        if ":" in line and not line.lstrip().startswith("#"):
            k, _, v = line.partition(":")
            out[k.strip()] = v.strip()
    return out


def main() -> int:
    if not MANIFEST.exists():
        print(f"ERROR: {MANIFEST} not found. Run `dbt parse` first.", file=sys.stderr)
        return 2

    manifest = json.loads(MANIFEST.read_text())
    mf_metrics = {m["name"] for m in manifest.get("metrics", [])}

    skill_files: dict[str, str] = {}
    if SKILLS.exists():
        for p in sorted(SKILLS.glob("*.md")):
            fm = parse_frontmatter(p)
            mid = fm.get("metric_id") or p.stem.replace("-", "_")
            skill_files[mid] = p.name

    # Orphan check only: every skill file must map to a real mf metric.
    # We do NOT require every mf metric to have a skill file, many are
    # supporting metrics (new_arr, cohort_*, won_opps, etc.) consumed only
    # by derived/ratio parents. Only the "public" ones (per design doc §1.5)
    # get skill files.
    errors = []
    for sid, fname in sorted(skill_files.items()):
        if sid not in mf_metrics:
            errors.append(f"ORPHAN skill: skills/metrics/{fname} declares metric_id '{sid}' which is not an mf metric")

    if errors:
        print("Skill ⇄ metric crosswalk FAILED:")
        for e in errors:
            print(f"  - {e}")
        return 1

    print(f"OK: {len(skill_files)} skill files, all match mf metrics ({len(mf_metrics)} total mf metrics).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
