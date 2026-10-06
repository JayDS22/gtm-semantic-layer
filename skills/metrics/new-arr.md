---
metric_id: new_arr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [segment, region, movement_type]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [net-new-arr, expansion-rate, nrr]
---

# New ARR, Brand-New-Logo ARR

## One-liner
ARR added by brand-new logos in the period, the first-paid-month contribution from accounts that had no prior paying history.

## Formula
`new_arr = sum(arr_delta_cents where movement_type = 'new')` over the period.

Divide by 100 for dollars. The `movement_type = 'new'` filter is pre-applied in the semantic model.

## Dimensions you can slice by
- `segment`, SMB / MM / ENT (via `account` entity join)
- `region`, NAMER / EMEA / APAC / LATAM
- `movement_type`, already filtered to `'new'`, but exposed for consistency with other movement metrics

## How to query
`mf query --metrics new_arr --group-by metric_time__month,account__segment`

## Gotchas
1. **Reactivations currently classify as 'new'.** An account that churned and then returned shows up here as new logo revenue. Day 4+ of the roadmap adds explicit prior-history detection; until then, reactivation inflates new_arr for churn-prone segments.
2. **First-paid-month cohorting.** Mid-month-start accounts land in their first-paid-month cohort, not the signup month. A contract signed on the 29th that bills on the 1st shows up in the following month's new_arr.

## When NOT to use new_arr
- Total growth including expansion from existing accounts → `net_new_arr`
- Pipeline / closed-won before billing starts → use SFDC opportunity metrics
- Logo count rather than ARR → use `new_logos`

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly on the first business day.
