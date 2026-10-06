#!/usr/bin/env python3
"""
Warn when skills/*/*.md frontmatter `last_reviewed_at` is older than N days.
Day 4: warn-only (exit 0 always). Flip to exit non-zero post-Day-5 if we want
to gate CI on skill-doc freshness.

Entry: python scripts/skill_freshness.py --max-days 90
"""
from __future__ import annotations

import argparse
import re
import sys
from datetime import date, datetime
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SKILLS = ROOT / "skills"


def parse_frontmatter(path: Path) -> dict:
    text = path.read_text()
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, flags=re.DOTALL)
    if not m:
        return {}
    out: dict[str, str] = {}
    for line in m.group(1).splitlines():
        if ":" in line and not line.lstrip().startswith("#"):
            k, _, v = line.partition(":")
            out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def parse_date(raw: str) -> date | None:
    if not raw:
        return None
    # Accept YYYY-MM-DD or full ISO datetime.
    try:
        return date.fromisoformat(raw[:10])
    except ValueError:
        try:
            return datetime.fromisoformat(raw).date()
        except ValueError:
            return None


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--max-days", type=int, default=90, help="freshness threshold")
    args = ap.parse_args()

    today = date.today()
    stale: list[tuple[Path, int, str]] = []
    missing: list[Path] = []
    scanned = 0

    if not SKILLS.exists():
        print(f"OK: no skills/ directory at {SKILLS}")
        return 0

    for p in sorted(SKILLS.glob("*/*.md")):
        scanned += 1
        fm = parse_frontmatter(p)
        raw = fm.get("last_reviewed_at")
        d = parse_date(raw) if raw else None
        if d is None:
            missing.append(p)
            continue
        age = (today - d).days
        if age > args.max_days:
            stale.append((p, age, raw))

    if missing:
        print(f"INFO: {len(missing)} skill file(s) missing last_reviewed_at:")
        for p in missing:
            print(f"  - {p.relative_to(ROOT)}")

    if stale:
        print(f"WARN: {len(stale)} skill file(s) older than {args.max_days}d:")
        for p, age, raw in stale:
            print(f"  - {p.relative_to(ROOT)}  last_reviewed_at={raw}  age={age}d")
    else:
        print(f"OK: 0 stale skill files (scanned {scanned}, threshold {args.max_days}d).")

    # Day 4: warn-only.
    return 0


if __name__ == "__main__":
    sys.exit(main())
