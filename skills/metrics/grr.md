---
metric_id: grr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [cohort_month, segment]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [nrr, expansion-rate, nrr-cohort-attribution]
---

# GRR — Gross Revenue Retention

## One-liner
Share of a cohort's t0 ARR we are still collecting today, capped at the t0 floor per account — so GRR measures leakage only and can never exceed 1.0.

## Formula
`GRR_t = cohort_retained_arr_t / cohort_t0_arr`

where `retained_arr_t = sum over cohort accounts of min(curr_arr, t0_arr)`.

The per-account `min()` cap is what makes GRR different from NRR: expansion above the t0 floor is discarded.

## Dimensions you can slice by
- `cohort_month` — the t0 month of the cohort
- `segment` — SMB / MM / ENT

## How to query
`mf query --metrics grr --group-by metric_time__month,cohort_arr__cohort_month`

## Gotchas
1. **The per-account cap is the metric.** Removing the `min(curr_arr, t0_arr)` cap collapses GRR into NRR. Any reviewer rewriting the macro should preserve the per-account cap, not a cohort-level cap — those are not the same thing.
2. **Static cohort attribution.** Like NRR, the denominator and the account set both freeze at t0. New logos acquired after t0 do not enter this cohort's GRR, ever. See `nrr-cohort-attribution.md`.

## When NOT to use GRR
- Growth including expansion → `nrr`
- Logo-count retention (unweighted by ARR) → `logo_retention`
- Period-over-period revenue change → `net_new_arr`

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly on the first business day, alongside NRR.
