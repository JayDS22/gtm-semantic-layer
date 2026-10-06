---
metric_id: arr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [segment, region, plan]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [mrr, net-new-arr, why-did-arr-move]
---

# ARR — Annual Recurring Revenue

## One-liner
Annualized subscription revenue we would collect at the END of a given period if nothing changed — the cumulative sum of every ARR movement up to that point in time.

## Formula
`ARR_t = sum of arr_delta_cents from t=-∞ to t` (cumulative). Divide by 100 for dollars.

ARR is a stock, not a flow. A query grouped by month returns the ARR balance at month-end, not the change within the month.

## Dimensions you can slice by
- `segment` — SMB / MM / ENT (via `account` entity join to `dim_account`)
- `region` — NAMER / EMEA / APAC / LATAM
- `plan` — current plan on the account

## How to query
`mf query --metrics arr --group-by metric_time__month`

## Gotchas
1. **Cumulative, not period delta.** Grouping by month returns ARR at end-of-month, NOT the change within the month. If someone asks "ARR by month" and expects period changes, they want `net_new_arr`.
2. **Design-doc §2.3 drift.** The original spec declared `arr` as `type: simple` on `arr_delta_cents` — that is semantically `net_new_arr`, not ARR. We ship `arr` as `type: cumulative` to match the metric's name and finance's expectation.

## When NOT to use ARR
- Period deltas / "what changed this month" → `net_new_arr`
- Account-level health investigation → query `fct_mrr_movement` directly

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly on the first business day.
