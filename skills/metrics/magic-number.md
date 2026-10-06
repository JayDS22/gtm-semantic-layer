---
metric_id: magic_number
category: metric
owner: gtm-analytics@example.com
confidence_tier: evolving
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [cac-payback-months, burn-multiple, net-new-arr]
---

# Magic Number, SaaS Sales Efficiency

## One-liner
Annualized ARR added per dollar of S&M spent. Greater than 1 generally means "scale up S&M", less than 0.5 means "fix fit before scaling". The classic shorthand for whether a growth engine is working.

## Formula
`net_new_arr × 4 / sm_spend`
Quarterly net new ARR annualized, divided by that quarter's S&M spend.

## Dimensions you can slice by
- `metric_time__quarter`, the native grain

## How to query
`mf query --metrics magic_number --group-by metric_time__quarter`

## Gotchas
1. **Simplified vs textbook.** Textbook is `(ARR_Q - ARR_{Q-1}) × 4 / S&M_{Q-1}`. We use `net_new_arr × 4 / S&M_{Q}`, same quantity in net terms, assuming all growth flows through fct_mrr_movement. The S&M-lag approximation is deliberate; prior-quarter S&M isn't easily joined without a lag model.
2. **Churn-heavy quarters depress magic_number toward 0 or negative.** This is directionally correct but can read catastrophically if a single enterprise logo churn skews the quarter. Pair with gross retention when interpreting.

## When NOT to use magic_number
- Payback-time view in months → use `cac_payback_months`
- Overall burn efficiency including R&D and G&A → use `burn_multiple`

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
