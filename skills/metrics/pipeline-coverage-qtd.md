---
metric_id: pipeline_coverage_qtd
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [team, close_date]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [pipeline-coverage, pipeline-coverage-strict-vs-qtd]
---

# Pipeline Coverage QTD — Inclusive (Open + Won / Quota)

## One-liner
The "inclusive" sibling of `pipeline_coverage` — counts closed_won deals in the current period toward coverage. Some sales orgs treat won deals as the highest-confidence pipeline, and want them in the numerator. Pick strict or QTD deliberately for your org; both ship.

## Formula
`qtd_pipeline_arr / quota_arr`

Where `qtd_pipeline_arr = open_pipeline_arr + closed_won_arr_in_period`. Same forecast_category filter on the open side as `pipeline_coverage`; closed_won adds everything that closed in the current period at full ARR.

## Dimensions you can slice by
- `team` — via `opportunity__owner_team`
- `close_date` — defaults to quarter grain

## How to query
`mf query --metrics pipeline_coverage_qtd --group-by metric_time__quarter,team`

## Gotchas
1. **Adversarial-pass sibling metric (design doc §4).** Exists specifically because two coverage definitions circulate in SaaS and neither is objectively wrong. Shipping both acknowledges that; your org should pick one as its headline and treat the other as reference.
2. **Trends upward through the quarter.** Because won deals accumulate, QTD coverage drifts up as the quarter progresses — strict `pipeline_coverage` usually drifts down as pipeline converts out. Don't compare the two trajectories head-to-head.

## When NOT to use pipeline_coverage_qtd
- Forward-looking "will we hit it?" view → use `pipeline_coverage`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly during the quarter.
