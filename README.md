# anthropic-gtm-semantic-layer

Governed, self-service GTM analytics stack built on dbt-core + MetricFlow + DuckDB/Snowflake, with a versioned `skills/` folder consumed by Claude-style assistants.

Inspired by Anthropic's June 2026 post *"How Anthropic enables self-service data analytics with Claude"*. The `skills/` folder pattern and the column-level PII taxonomy are a sincere reconstruction from the published post; the metric definitions, warehouse schema, and tests are original work.

## What's in here

- **dbt-core** warehouse — DuckDB locally, Snowflake profile wired for parity with real production
- **MetricFlow** semantic layer declaring 20 GTM metrics (ARR, NRR, pipeline coverage, funnel conversions, CAC payback, etc.)
- **`skills/`** — one markdown file per metric + debug runbooks + FAQs, each with YAML frontmatter so an assistant can filter by owner, PII sensitivity, and review cadence
- **CI** that builds the warehouse, validates MetricFlow configs, snapshots metrics against golden files, and walks the manifest to enforce PII tag propagation

## Run locally

```bash
make up        # pip install, dbt deps/seed/build
make test      # dbt test
make q METRIC=arr GROUP=metric_time__month
```

Requires Python 3.11+. No cloud credentials needed — DuckDB is the default target.

## Status

- [x] Day 1 — Skeleton, seeds, 3 staging models, source YAML, CI green
- [ ] Day 2 — Marts + first 5 metrics
- [ ] Day 3 — Remaining 15 metrics + `skills/`
- [ ] Day 4 — PII enforcement + singular tests + snapshot tests
- [ ] Day 5 — README polish + architecture diagram + Loom + public

See `BUILD-LOG.md` for daily shipping notes.

## Attribution

The `skills/` folder pattern and PII taxonomy are reconstructed from Anthropic's June 2026 Claude-for-analytics post. Metric definitions, warehouse schema, dbt macros, and CI are mine, written against open sources (dbt-labs canonical layering, standard GTM metric formulas).
