---
metric_id: mql_to_sql_conv
category: metric
owner: gtm-analytics@example.com
confidence_tier: evolving
dimensions: [segment, source, cohort_week]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [sql-to-won-conv, mql-to-won-conv, activation-rate]
---

# MQL to SQL Conversion

## One-liner
Share of MQLs that progressed to SQL within the same cohort period. Measures the "qualified by marketing → qualified by sales" handoff step and surfaces lead-quality or SDR-capacity issues early.

## Formula
`funnel_sqls / funnel_mqls`

Numerator and denominator are counted over the same time bucket.

## Dimensions you can slice by
- `segment` — SMB / mid-market / enterprise
- `source` — acquisition channel (paid, organic, referral)
- `cohort_week` — week the MQL fired

## How to query
`mf query --metrics mql_to_sql_conv --group-by metric_time__week`

## Gotchas
1. **Proxy aggregation.** Current semantic model counts distinct users with `funnel_stage='mql'` and `'sql'` in the SAME bucket — true cohort tracking requires joining each user's MQL event to their later SQL event (which may be weeks later). Day 4+ work.
2. **High-intent inbound skips MQL.** Users who jumped straight from signup to SQL aren't in the MQL set and don't contribute to the numerator — this metric understates fast-path conversion.

## When NOT to use mql_to_sql_conv
- Full-funnel view → chain into `mql_to_won_conv`
- SQL → opportunity match → joins `fct_funnel_event` to `fct_opportunity` (not yet wired)

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly.
