---
metric_id: sql_to_won_conv
category: metric
owner: gtm-analytics@example.com
confidence_tier: evolving
dimensions: [segment, source, team, cohort_week]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [mql-to-sql-conv, mql-to-won-conv, win-rate]
---

# SQL to Won Conversion

## One-liner
Share of SQLs that progressed to Won within the same cohort period. Measures sales execution post-qualification, once a lead is sales-accepted, how often does the team actually close it?

## Formula
`funnel_wons / funnel_sqls`

Both counts bucketed over the same time window.

## Dimensions you can slice by
- `segment`, SMB / mid-market / enterprise
- `source`, original acquisition channel
- `team`, closing sales team
- `cohort_week`, week the SQL fired

## How to query
`mf query --metrics sql_to_won_conv --group-by metric_time__week`

## Gotchas
1. **Proxy data for wins.** `funnel_wons` uses `expansion_event` from product events as a lightweight stand-in, the real "won" signal lives in `fct_opportunity.is_won`. Day 4+ joins the two facts for a trustworthy number.
2. **Within-period aggregation, not per-user tracked progression.** Same cohort caveat as `mql_to_sql_conv`, if a user's SQL fires in week 1 and their win in week 6, they land in different buckets.

## When NOT to use sql_to_won_conv
- Deal-value-weighted view → `win_rate × arr_cents`
- Sales rep performance → `win_rate`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly.
