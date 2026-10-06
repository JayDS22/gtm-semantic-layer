---
metric_id: pipeline_coverage
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [team, close_date]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [pipeline-coverage-qtd, win-rate, weighted-pipeline-arr, pipeline-coverage-strict-vs-qtd]
---

# Pipeline Coverage — Strict (Open Pipeline / Quota)

## One-liner
How much open pipeline we have relative to the period's quota. ≥3x is the industry rule-of-thumb for a hittable quarter. The strict, forward-looking definition — closed_won in-period is NOT counted (it's already in the bag, not pipeline).

## Formula
`open_pipeline_arr / quota_arr`

Where `open_pipeline_arr = sum(arr_cents)` for OPEN opportunities whose `forecast_category ∈ (pipeline, best_case, commit)`. Quota is per team per period from `dim_quota`.

## Dimensions you can slice by
- `team` — via `opportunity__owner_team`
- `close_date` — defaults to quarter grain

## How to query
`mf query --metrics pipeline_coverage --group-by metric_time__quarter,team`

## Gotchas
1. **Strict denominator — excludes closed_won in-period.** The "QTD coverage" sibling exists as `pipeline_coverage_qtd` for teams that want to count won deals toward coverage. See the `pipeline-coverage-strict-vs-qtd` FAQ for which to pick.
2. **Opinionated forecast_category filter.** `omitted` is NOT counted. Teams that treat `omitted` as "unlikely but tracked" would broaden this — our definition stays strict so a 3x number means 3x of real forecast-eligible pipeline.

## When NOT to use pipeline_coverage
- QTD progress tracking (how we're pacing including wins) → use `pipeline_coverage_qtd`
- Probability-weighted expected ARR → use `weighted_pipeline_arr`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly during the quarter.
