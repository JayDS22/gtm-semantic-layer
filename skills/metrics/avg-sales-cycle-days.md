---
metric_id: avg_sales_cycle_days
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [team, segment, close_date]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [win-rate, pipeline-coverage]
---

# Avg Sales Cycle Days, Mean Days from Create to Close

## One-liner
Average number of days between an opportunity's created_date and its close_date, across closed opps in the period. A capacity-planning number, how long a rep's inventory of pipeline needs to be before quota lands.

## Formula
`sum(cycle_days on closed opps) / count(closed opps with cycle)`

Where `cycle_days = close_date − created_date`. Only closed opps contribute, open opps have null cycle_days and are excluded.

## Dimensions you can slice by
- `team`, via `opportunity__owner_team`
- `segment`, SMB / MM / ENT (via account join)
- `close_date`, defaults to quarter grain

## How to query
`mf query --metrics avg_sales_cycle_days --group-by metric_time__quarter,opportunity__owner_team`

## Gotchas
1. **Open opps are excluded from the denominator.** Intentional, an open opp has no cycle yet, but worth stating when you report, because a team with a long-running open-opp backlog won't see that pressure in this metric.
2. **Mean, not median.** A single 400-day enterprise deal in a cohort of forty 50-day SMB deals shifts the average by ~15 days. Day 4+ of this project may add p50/p90 variants; the mean is the headline for now.

## When NOT to use avg_sales_cycle_days
- Deal-size pacing or ramp → look at ARR movement over time
- Rep performance ranking → start with `win_rate`, not cycle length

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly.
