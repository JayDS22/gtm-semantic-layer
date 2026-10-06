---
metric_id: rule_of_40
category: metric
owner: gtm-analytics@example.com
confidence_tier: draft
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [magic-number, burn-multiple, gross-margin]
---

# Rule of 40 — SaaS Health Shorthand

## One-liner
The classic SaaS health shorthand: either growing fast OR profitable OR some mix of both totaling at least 40. Popularized by Bessemer and Brad Feld as a single-number sanity check that balances growth against efficiency.

## Formula
`growth_rate_pct + operating_margin_pct`
Should sum to ≥ 40 for a "healthy" SaaS. **Day 3 implementation ships `operating_margin_pct × 100` only** — the growth-rate term is pending.

## Dimensions you can slice by
- `metric_time__quarter` — the standard reporting grain

## How to query
`mf query --metrics rule_of_40 --group-by metric_time__quarter`

## Gotchas
1. **Day 3 ships operating-margin only.** The growth-rate component requires period-over-period ARR computed as a metric (needs a `fct_arr_qoq_growth` mart that isn't built). Day 4+ fix. Until then, this metric substantially under-reports a growing-but-unprofitable company — e.g., an early-stage SaaS at 90% growth / -60% operating margin should score 30, we'd currently report -60. Do not use this for external benchmarking yet.
2. **Operating margin convention varies.** We use GAAP-ish operating margin, not FCF margin — adjust if your reports use free cash flow. Bessemer's original write-up permits either; stay consistent within a comparison set.

## When NOT to use rule_of_40
- Growth signal alone → ARR trajectory plus `magic_number`
- Profitability alone → `gross_margin` plus operating_margin_pct

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
