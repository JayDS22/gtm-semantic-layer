#!/usr/bin/env python3
"""
Minimal demo of the skills/-folder consumption pattern.

A Claude-style assistant, given a GTM question in plain English, reads the
skills/ folder (23 metric cards + runbooks + FAQs), picks the right skill,
and emits a deterministic MetricFlow query. This script skips the LLM call
and uses a keyword scorer in its place: same control flow, same read of the
skill frontmatter, same emitted command. In production the keyword scorer
is replaced by any model that can rank skill files; the deterministic query
is what matters.

Usage:
    ./scripts/ask_claude.py "what's our ARR trending by month?"
    ./scripts/ask_claude.py "show CAC payback by quarter" --run
"""
from __future__ import annotations

import argparse
import pathlib
import re
import subprocess
import sys

SKILLS_DIR = pathlib.Path(__file__).resolve().parents[1] / "skills" / "metrics"

GRAIN_HINTS = {
    "quarter": "metric_time__quarter",
    "quarterly": "metric_time__quarter",
    "qoq": "metric_time__quarter",
    "month": "metric_time__month",
    "monthly": "metric_time__month",
    "mom": "metric_time__month",
    "week": "metric_time__week",
    "weekly": "metric_time__week",
}

COHORT_HINTS = ("cohort", "retention", "nrr", "grr")


def load_skills() -> list[tuple[str, str, str]]:
    """Return (metric_id, title, body) for every skill card."""
    skills = []
    for path in sorted(SKILLS_DIR.glob("*.md")):
        text = path.read_text()
        metric_match = re.search(r"^metric_id:\s*(\S+)", text, re.MULTILINE)
        title_match = re.search(r"^#\s+(.+)$", text, re.MULTILINE)
        if metric_match and title_match:
            skills.append((metric_match.group(1), title_match.group(1), text.lower()))
    return skills


def pick_skill(question: str, skills: list[tuple[str, str, str]]) -> tuple[str, str, int]:
    """Score every skill against the question; return the best (metric_id, title, score).

    Weights are tuned so an exact-metric-name match wins over body co-mentions,
    and a metric_id whose tokens are all requested beats one whose id has
    unrequested tokens (so `arr` beats `new_arr` when "new" isn't asked for).
    """
    q_tokens = set(t for t in re.findall(r"[a-z0-9]+", question.lower()) if len(t) > 1)
    best = ("", "", -1)
    for metric_id, title, body in skills:
        id_tokens = set(re.findall(r"[a-z0-9]+", metric_id))
        title_tokens = set(re.findall(r"[a-z0-9]+", title.lower()))
        hit_id = q_tokens & id_tokens
        miss_id = id_tokens - q_tokens
        score = 50 * len(hit_id) + 15 * len(q_tokens & title_tokens)
        score -= 25 * len(miss_id)
        for t in q_tokens:
            score += min(body.count(t), 3)
        if score > best[2]:
            best = (metric_id, title, score)
    return best


def pick_grain(question: str) -> str:
    for hint, grain in GRAIN_HINTS.items():
        if hint in question.lower():
            return grain
    return "metric_time__month"


def build_group_by(question: str, grain: str) -> str:
    if any(h in question.lower() for h in COHORT_HINTS):
        return f"{grain},cohort_arr_row__cohort_month__month"
    return grain


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("question", help="plain-English GTM question")
    ap.add_argument("--run", action="store_true", help="execute the resolved mf query")
    args = ap.parse_args()

    skills = load_skills()
    metric_id, title, score = pick_skill(args.question, skills)
    if not metric_id:
        print("no matching skill found", file=sys.stderr)
        return 1

    grain = pick_grain(args.question)
    group_by = build_group_by(args.question, grain)
    venv_mf = pathlib.Path(__file__).resolve().parents[1] / ".venv" / "bin" / "mf"
    mf_bin = str(venv_mf) if venv_mf.exists() else "mf"
    cmd = [mf_bin, "query", "--metrics", metric_id, "--group-by", group_by, "--order", grain]
    if "cohort_arr_row" in group_by:
        cmd += ["--limit", "12"]

    display_cmd = ["mf", *cmd[1:]]
    print(f"User: {args.question}")
    print(f"Claude: read skills/metrics/{metric_id.replace('_', '-')}.md  ->  {title}")
    print(f"        resolved grain: {grain}")
    print(f"        emitting: {' '.join(display_cmd)}")
    print()

    if args.run:
        return subprocess.call(cmd)
    print("(dry-run; pass --run to execute)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
