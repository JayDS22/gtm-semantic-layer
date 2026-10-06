---
metric_id: burn_multiple
category: metric
owner: gtm-analytics@example.com
confidence_tier: evolving
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [magic-number, cac-payback-months, net-new-arr]
---

# Burn Multiple, Capital Efficiency

## One-liner
Dollars burned per dollar of ARR added. Less than 1 is strong; 1-2 is typical for growth-stage SaaS; greater than 2 is a warning threshold. Popularized by Craft Ventures as the single best capital-efficiency metric for private SaaS.

## Formula
`net_burn / net_new_arr`
Net cash burn in the period divided by net new ARR added in the same period.

## Dimensions you can slice by
- `metric_time__quarter`, the standard reporting grain

## How to query
`mf query --metrics burn_multiple --group-by metric_time__quarter`

## Gotchas
1. **Zero- or negative-ARR quarters.** If net_new_arr ≤ 0, burn_multiple is undefined / meaningless. The `nullif` in the derived expr returns null to avoid div-by-zero; report consumers must handle the null rather than render it as 0.
2. **Burn is pre-tax, pre-financing-change.** Our financials seed treats net_burn as straight cash out of operations; capital raises, convertible notes, interest income, and FX effects aren't netted. Use operating-cash-flow when the question is runway rather than efficiency.

## When NOT to use burn_multiple
- Unit-economics view by cohort → use `cac_payback_months`
- Fit-check before scaling S&M → use `magic_number`

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
