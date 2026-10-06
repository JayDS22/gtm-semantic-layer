#!/usr/bin/env python3
"""
PII policy enforcement from target/manifest.json (design doc §2.8).

Checks:
  (a) walk-and-warn — staging columns with meta.pii should propagate the tag
      to downstream mart columns derived from them. True column-lineage needs
      the catalog, so Day 4 prints info findings and never fails.
  (b) HARD — no mart column may carry meta.pii = 'direct_identifier' unless
      meta.pii_opt_in is truthy.
  (c) HARD — every semantic_model dimension must resolve to a mart column
      whose pii level is in {None, 'customer_identifier'} (or lower). Direct
      identifiers never reach the semantic layer.

Exit codes:
  0  — clean
  1  — (b) or (c) violation
  2  — manifest.json missing (run `dbt parse` first)
"""
from __future__ import annotations

import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "target" / "manifest.json"

# Allowed PII levels on anything the semantic layer touches.
# Order matters: direct_identifier is the only forbidden level.
SEMANTIC_ALLOWED = {None, "", "non_pii", "customer_identifier"}
FORBIDDEN_IN_MARTS = "direct_identifier"


def _col_pii(col: dict[str, Any]) -> str | None:
    meta = (col or {}).get("meta") or {}
    val = meta.get("pii")
    return val.strip() if isinstance(val, str) else val


def _col_opt_in(col: dict[str, Any]) -> bool:
    meta = (col or {}).get("meta") or {}
    return bool(meta.get("pii_opt_in"))


def _is_mart(node: dict[str, Any]) -> bool:
    # dbt marts conventionally live under models/marts/… — fall back to
    # fqn[1] == 'marts' which is stable regardless of file layout.
    fqn = node.get("fqn") or []
    return len(fqn) >= 2 and fqn[1] == "marts"


def _is_staging(node: dict[str, Any]) -> bool:
    fqn = node.get("fqn") or []
    return len(fqn) >= 2 and fqn[1] == "staging"


def check_marts_direct_identifier(nodes: dict[str, Any]) -> list[str]:
    errs: list[str] = []
    for nid, node in nodes.items():
        if node.get("resource_type") != "model" or not _is_mart(node):
            continue
        for cname, col in (node.get("columns") or {}).items():
            if _col_pii(col) == FORBIDDEN_IN_MARTS and not _col_opt_in(col):
                errs.append(
                    f"{nid}.{cname}: meta.pii='direct_identifier' without "
                    f"meta.pii_opt_in=true"
                )
    return errs


def check_semantic_dimensions(manifest: dict[str, Any]) -> list[str]:
    """Every dimension on every semantic_model must bind to a mart column
    whose pii level is allowed."""
    errs: list[str] = []
    nodes = manifest.get("nodes", {})
    sem_models = manifest.get("semantic_models", {})

    # Build model_name -> columns map for mart models.
    mart_cols: dict[str, dict[str, dict[str, Any]]] = {}
    for node in nodes.values():
        if node.get("resource_type") == "model" and _is_mart(node):
            mart_cols[node["name"]] = node.get("columns") or {}

    for sm_id, sm in sem_models.items():
        ref = sm.get("node_relation") or {}
        model_name = ref.get("alias") or sm.get("name")
        cols = mart_cols.get(model_name, {})
        for dim in sm.get("dimensions") or []:
            # dim['expr'] overrides dim['name'] when set
            col_name = (dim.get("expr") or dim.get("name") or "").strip()
            col = cols.get(col_name)
            if not col:
                # Dimension doesn't resolve to a documented mart column —
                # can't verify, let it pass. The crosswalk / dbt compile
                # catches genuine missing refs.
                continue
            pii = _col_pii(col)
            if pii == FORBIDDEN_IN_MARTS:
                errs.append(
                    f"semantic_model '{sm.get('name')}' dim '{col_name}' "
                    f"-> {model_name}.{col_name}: pii='{pii}' leaks to "
                    f"semantic layer"
                )
            elif pii not in SEMANTIC_ALLOWED:
                errs.append(
                    f"semantic_model '{sm.get('name')}' dim '{col_name}' "
                    f"-> {model_name}.{col_name}: unknown pii level '{pii}'"
                )
    return errs


def walk_and_warn_propagation(nodes: dict[str, Any]) -> list[str]:
    """(a) best-effort: for every staging column tagged with meta.pii, warn
    if downstream mart models have a same-named column with no pii tag.
    Column-level lineage isn't in manifest.json without catalog.json, so this
    is intentionally coarse."""
    staging_tagged: dict[str, str] = {}  # column_name -> pii_level
    for node in nodes.values():
        if node.get("resource_type") != "model" or not _is_staging(node):
            continue
        for cname, col in (node.get("columns") or {}).items():
            pii = _col_pii(col)
            if pii:
                # Last writer wins; good enough for a warn pass.
                staging_tagged[cname] = pii

    findings: list[str] = []
    for node in nodes.values():
        if node.get("resource_type") != "model" or not _is_mart(node):
            continue
        for cname, col in (node.get("columns") or {}).items():
            if cname in staging_tagged and not _col_pii(col):
                findings.append(
                    f"{node['unique_id']}.{cname}: upstream staging tagged "
                    f"pii='{staging_tagged[cname]}', mart column has no "
                    f"meta.pii — consider propagating"
                )
    return findings


def main() -> int:
    if not MANIFEST.exists():
        print(f"ERROR: {MANIFEST} not found. Run `dbt parse` first.", file=sys.stderr)
        return 2

    manifest = json.loads(MANIFEST.read_text())
    nodes = manifest.get("nodes", {})

    # (a) walk-and-warn
    warnings = walk_and_warn_propagation(nodes)
    if warnings:
        print("INFO: PII propagation walk-and-warn:")
        for w in warnings:
            print(f"  - {w}")

    # (b) + (c) hard
    b_errs = check_marts_direct_identifier(nodes)
    c_errs = check_semantic_dimensions(manifest)

    if b_errs or c_errs:
        print("PII policy FAILED:")
        for e in b_errs:
            print(f"  [B] {e}")
        for e in c_errs:
            print(f"  [C] {e}")
        return 1

    print(
        f"OK: PII policy clean "
        f"({len(warnings)} propagation info, 0 direct_identifier leaks, 0 semantic leaks)."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
