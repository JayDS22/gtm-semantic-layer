---
metric_id: logo_retention
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [cohort_month, segment]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [grr, nrr, how-do-we-define-churn]
---

# Logo Retention — Account Count Retention

## One-liner
Share of cohort accounts still paying at the reporting month. Dollar-agnostic — a $10/mo retained logo counts the same as a $100k/yr retained logo. Useful for product-led motions where account count is the health signal, not ARR.

## Formula
`cohort_logo_now_count / cohort_logo_t0_count`

Numerator = count of accounts from the cohort that are still active (any paying subscription) at the reporting period. Denominator = count of accounts in the cohort at acquisition (t=0).

## Dimensions you can slice by
- `cohort_month` — acquisition month of the cohort
- `segment` — SMB / MM / ENT

## How to query
`mf query --metrics logo_retention --group-by metric_time__month,cohort_arr__cohort_month`

## Gotchas
1. **Logo retention and GRR diverge for enterprise cohorts.** One retained ENT logo keeps GRR high but is counted the same as one retained SMB logo here. For heavy-ENT cohorts, logo_retention can look mediocre while GRR looks great (and vice versa).
2. **Pause/past_due counts as "still paying."** An account is considered retained if its last valid day in `int_subscription_mrr_daily` is current — this includes `active` and `past_due` states. Hard-cancelled accounts drop out.

## When NOT to use logo_retention
- Dollar-weighted retention (what finance usually wants) → use `grr`
- Expansion component → use `expansion_rate`

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly.
