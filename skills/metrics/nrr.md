---
metric_id: nrr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [cohort_month, segment, region, plan]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [arr, expansion-rate, nrr-cohort-attribution]
---

# NRR — Net Revenue Retention

## One-liner
For a cohort of accounts that were paying at month t0, NRR is the share of that cohort's ARR we still have today, including expansion from those same accounts but excluding any ARR from accounts that joined after t0.

## Formula
`NRR_t = (retained_arr_t + expansion_arr_t - contraction_arr_t - churn_arr_t) / cohort_t0_arr`

Numerator and denominator both sum over the SAME set of accounts (the ones in the cohort at t0). This is the whole point.

## Dimensions you can slice by
- `cohort_month` — the t0 month of the cohort
- `segment` — SMB / MM / ENT
- `region` — NAMER / EMEA / APAC / LATAM
- `plan` — the plan the account was on at t0 (NOT the current plan)

## How to query
`mf query --metrics nrr --group-by metric_time__month,cohort_arr__cohort_month`

## Gotchas
1. **Cohort attribution is static.** Expansion from a new logo acquired this quarter does not count toward any existing cohort's NRR.
2. **Denominator freezes at t0.** Downgrades to the t0 account are contraction (hurts NRR); downgrades on NEW accounts don't show up here.

## When NOT to use NRR
- Logo-level health → use `logo_retention`
- New business efficiency → use `cac_payback_months`

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly on the first business day.
