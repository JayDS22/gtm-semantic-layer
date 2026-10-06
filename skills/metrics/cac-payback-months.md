---
metric_id: cac_payback_months
category: metric
owner: gtm-analytics@example.com
confidence_tier: draft
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [magic-number, burn-multiple, gross-margin, cac-payback]
---

# CAC Payback Months, Sales & Marketing Payback Period

## One-liner
Months for S&M spend to be repaid by gross profit on new ARR. Lower is better; 12-18 months is healthy for SaaS, >24 months signals efficiency pain and usually means segment mix, pricing, or sales motion needs rework before scaling further.

## Formula
`12 × sm_spend / (new_arr × gross_margin_pct)`
S&M dollars divided by annualized gross profit on new ARR, expressed in months.

## Dimensions you can slice by
- `metric_time__quarter`, quarterly S&M vs new ARR
- `segment`, future, see gotcha 1

## How to query
`mf query --metrics cac_payback_months --group-by metric_time__quarter`

## Gotchas
1. **Blended, not segment-weighted.** Design doc §2.3 metric 16 specifies a segment-weighted CAC payback that weights by segment ARR mix × per-segment gross margin, the right formula when segment economics diverge (ENT typically 60-80% GM, SMB often <50%). We ship the blended version in Day 3 because per-segment gross margin and segment mix seeds aren't authored yet. Day 4+ fix.
2. **S&M lags ARR by a quarter in reality.** The strict formula uses S&M_{Q-1} vs new ARR_Q, we match the same period for simplicity. Expect noise on quarter boundaries where S&M was spent to land next quarter's ARR.

## When NOT to use cac_payback_months
- Segment-economics view → wait for Day 4+ segment-weighted version
- Investor-facing efficiency framing → use `magic_number`

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
