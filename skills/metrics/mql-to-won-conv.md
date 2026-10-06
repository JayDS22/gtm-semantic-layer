---
metric_id: mql_to_won_conv
category: metric
owner: gtm-analytics@example.com
confidence_tier: evolving
dimensions: [source, segment, cohort_week]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [mql-to-sql-conv, sql-to-won-conv, cac-payback-months]
---

# MQL to Won Conversion

## One-liner
End-to-end marketing conversion: MQL to closed-won. The top-of-funnel efficiency number marketing leaders use to justify spend and tune channel mix.

## Formula
`funnel_wons / funnel_mqls`

Both counts bucketed over the same cohort period.

## Dimensions you can slice by
- `source` — acquisition channel
- `segment` — SMB / mid-market / enterprise
- `cohort_week` — week the MQL fired

## How to query
`mf query --metrics mql_to_won_conv --group-by metric_time__week`

## Gotchas
1. **Compounds both proxy caveats** of `mql_to_sql_conv` and `sql_to_won_conv` — expansion-event proxy for wins + within-period aggregation. Reads as low numerator / high denominator today.
2. **Lagged attribution.** Real wins happen weeks or months after the original MQL, so this metric reads conservatively in-period. Don't compare recent weeks to older weeks until the newer cohorts have had time to mature.

## When NOT to use mql_to_won_conv
- Step-level diagnosis → use `mql_to_sql_conv` + `sql_to_won_conv` separately
- CAC math → use `cac_payback_months`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly.
