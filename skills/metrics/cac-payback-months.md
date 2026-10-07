---
metric_id: cac_payback_months
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-07
update_cadence: quarterly
related_skills: [magic-number, burn-multiple, gross-margin]
---

# CAC Payback Months, Sales & Marketing Payback Period

## One-liner
Months for S&M spend to be repaid by gross profit on new ARR. Lower is better; 12-18 months is healthy for SaaS, >24 months signals efficiency pain and usually means segment mix, pricing, or sales motion needs rework before scaling further.

## Formula
Segment-weighted per design doc §2.3 metric 16:

```
cac_payback_months = 12 * sm_spend / sum(new_arr_s * gm_s * mix_s)
                                     s in {SMB, MM, ENT}
```

Where `new_arr_s` is new ARR in segment `s` for the quarter (derived from `fct_mrr_movement` joined to `dim_account.segment` in `int_new_arr_by_segment`), `gm_s` is that segment's gross margin, `mix_s` is the segment's share of the account base. Day 5 polish: `new_arr_s` is derived from the warehouse (not seeded); only `gm_s` and `mix_s` remain in the `segment_margins` seed where real finance data would otherwise live.

## Dimensions you can slice by
- `metric_time__quarter`, quarterly S&M vs blended new ARR
- A per-segment CAC payback would need per-segment S&M allocation; see gotcha 2

## How to query
`mf query --metrics cac_payback_months --group-by metric_time__quarter`

## Gotchas
1. **S&M lags ARR by a quarter in reality.** The textbook formula uses `S&M_{Q-1}` vs `new ARR_Q`; we match the same period for simplicity. Expect noise on quarter boundaries where S&M was spent to land next quarter's ARR.
2. **Per-segment S&M allocation is NOT modeled.** The numerator `sm_spend` is a single blended quarter number from `fct_financials`; a strict per-segment CAC payback would allocate S&M to each segment and compute per-segment ratios. Appropriate when AE comp and marketing programs are segmented, deferred until a credible allocation is available in `fct_financials`.
3. **GM and mix are seeded (finance system normally sources them).** `segment_margins.csv` carries 12 rows (4 quarters x 3 segments) with hand-set `gross_margin_pct` and `segment_mix_pct`. In production, these come from the finance system (cost allocation) and the GTM org chart; swap the seed for a source YAML pointing at those tables.

## When NOT to use cac_payback_months
- Per-segment economics view, deferred until per-segment S&M allocation lands
- Investor-facing efficiency framing, use `magic_number`
- Dollar-burn ratio, use `burn_multiple`

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
