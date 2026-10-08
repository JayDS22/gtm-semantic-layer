---
metric_id: arr_qoq_annualized_growth_pct
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-07
update_cadence: quarterly
related_skills: [rule-of-40, arr, net-new-arr]
---

# ARR QoQ-Annualized Growth

## One-liner
ARR growth rate at quarter-end, quarter-over-quarter, annualized. Powers the growth-rate term of `rule_of_40`. For a company at $10M ARR growing to $12M in one quarter, this reports 107% (annualized), not 20% (quarterly).

## Formula
```
arr_qoq_annualized_growth_pct = (1 + (ARR_q - ARR_{q-1}) / ARR_{q-1})^4 - 1
```

Where `ARR_q` is total ARR at the last observed month of quarter `q`, summed across all accounts. Implemented in `fct_arr_qoq_growth` (quarter-end ARR + lag(1) over quarter_start). Partial quarters (where the third month has not yet been observed) are excluded.

## Dimensions you can slice by
- `metric_time__quarter`, the only grain for this metric

## How to query
`mf query --metrics arr_qoq_annualized_growth_pct --group-by metric_time__quarter`

## Gotchas
1. **YoY vs QoQ-annualized is a convention choice.** Bessemer's canonical Rule-of-40 definition uses trailing-12-month ARR growth (YoY). QoQ-annualized is accepted for high-growth stage companies where YoY is too lagged (a $5M → $20M jump in 3 quarters reads differently YoY vs QoQ-ann). This repo uses QoQ-annualized because the demo seed has only 4 complete quarters; a 5-quarter history is needed before YoY produces any non-null value. Production deployments should add a parallel `arr_yoy_growth_pct` once >= 5 quarters of warehouse history is available and switch `rule_of_40` to YoY for cross-company benchmarking.
2. **Partial quarters are excluded.** `fct_arr_qoq_growth` filters to quarters where the third month has been observed. The first incomplete quarter of the demo seed (2026-10) is excluded from output.
3. **Hypergrowth distortion.** QoQ-annualized compounds a single quarter's growth four times. A one-time 2x jump (e.g., closing a major enterprise deal) reads as 1500% annualized. For companies past the hypergrowth phase (ARR > $100M), prefer YoY to smooth lumpy quarters.

## When NOT to use arr_qoq_annualized_growth_pct
- Cross-company benchmarking at scale, use YoY
- Monthly cadence reporting, this metric is quarterly-only by construction
- Attributing growth to new vs expansion ARR, use `new_arr` + `expansion_rate` separately

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
