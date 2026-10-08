---
metric_id: rule_of_40
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-07
update_cadence: quarterly
related_skills: [magic-number, burn-multiple, gross-margin, arr-qoq-growth-pct]
---

# Rule of 40, SaaS Health Shorthand

## One-liner
The classic SaaS health shorthand: either growing fast OR profitable OR some mix of both totaling at least 40. Popularized by Bessemer and Brad Feld as a single-number sanity check that balances growth against efficiency.

## Formula
```
rule_of_40 = (arr_growth_pct + operating_margin_pct) * 100
```

Should sum to >= 40 for a "healthy" SaaS. This repo wires `arr_growth_pct = arr_qoq_annualized_growth_pct` from `fct_arr_qoq_growth` and `operating_margin_pct = operating_margin_pct_metric` from `fct_financials`. Both terms are percentages (not percentage points), hence the `* 100` at the end.

## Dimensions you can slice by
- `metric_time__quarter`, the only grain

## How to query
`mf query --metrics rule_of_40 --group-by metric_time__quarter`

## Gotchas
1. **Growth-rate convention.** Bessemer's canonical definition uses YoY ARR growth; this repo uses QoQ-annualized because the demo seed only carries 4 complete quarters (YoY would be null everywhere). See `arr-qoq-growth-pct.md` for the full tradeoff. For cross-company benchmarking in production, flip to YoY once >= 5 quarters of history exist.
2. **Operating margin convention varies.** We use GAAP-ish operating margin from `fct_financials.operating_margin_pct`, not FCF margin. Bessemer's original write-up permits either; stay consistent within a comparison set.
3. **First quarter is null.** Growth term requires one prior quarter of ARR, so the first quarter of any warehouse history returns null `rule_of_40`.
4. **Hypergrowth distortion.** For companies 2x-ing ARR per quarter, the QoQ-annualized growth term explodes (1500%+ scores). The metric is designed for mature SaaS (ARR > $20M, growing 50-150%/yr); interpret with caution in the hypergrowth stage.

## When NOT to use rule_of_40
- Growth signal alone, use `arr_qoq_annualized_growth_pct` or ARR trajectory + `magic_number`
- Profitability alone, use `gross_margin` + operating margin
- Cash runway questions, use `burn_multiple`

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
