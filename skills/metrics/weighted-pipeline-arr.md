---
metric_id: weighted_pipeline_arr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [team, stage, forecast_category, close_date]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [pipeline-coverage, open-pipeline-arr, win-rate]
---

# Weighted Pipeline ARR

## One-liner
Pipeline value adjusted for stage-based close probability — a $100k opp in Negotiation (70%) contributes $70k to this metric. Gives sales leaders a probability-weighted view of what pipeline is likely to actually land, not just what's open.

## Formula
`sum(arr_cents × stage_probability)`

Hardcoded stage probabilities: Prospecting 0.10, Qualification 0.20, Discovery 0.30, Proposal 0.50, Negotiation 0.70, Closed Won 1.00, Closed Lost 0.00.

## Dimensions you can slice by
- `team` — owning sales team
- `stage` — opportunity stage (also drives the weight)
- `forecast_category` — rep-set forecast bucket (commit, best case, pipeline)
- `close_date` — expected close month/quarter

## How to query
`mf query --metrics weighted_pipeline_arr --group-by metric_time__quarter,opportunity__stage`

## Gotchas
1. **Flat default probabilities.** Stage probs are not learned from history — real orgs calibrate them against actual conversion by segment. Day 5+ enrichment.
2. **Won deals stay in the number.** Closed Won weights at 100%, so weighted_pipeline grows WITH wins rather than draining. For forward-only view use `pipeline_coverage` or `open_pipeline_arr`.

## When NOT to use weighted_pipeline_arr
- Pure forward pipeline → use `open_pipeline_arr`
- Historical performance → use `win_rate × avg deal size`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly.
