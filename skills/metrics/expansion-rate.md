---
metric_id: expansion_rate
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [cohort_month, segment]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [nrr, grr, nrr-cohort-attribution]
---

# Expansion Rate — Cohort Expansion

## One-liner
The share of a cohort's starting ARR that has grown above its t=0 baseline. Captures only upsell/cross-sell lift from accounts the cohort started with — never new logos. Pairs with GRR to decompose NRR into "kept" vs "grew".

## Formula
`(cohort_now_arr - cohort_retained_arr) / cohort_t0_arr`

The numerator is the above-t0 portion of the cohort's current ARR — i.e., only the dollars by which surviving accounts exceed what they paid at cohort start. Contraction below t0 does NOT reduce the numerator (that lives in GRR).

## Dimensions you can slice by
- `cohort_month` — the month the account was acquired (via `cohort_arr` entity)
- `segment` — SMB / MM / ENT

## How to query
`mf query --metrics expansion_rate --group-by metric_time__month,cohort_arr__cohort_month`

## Gotchas
1. **Cohort-static.** Expansion is anchored to the cohort's original members. Upgrades on a NEW logo acquired in-period do NOT count toward any prior cohort's expansion — they land in `new_arr` instead.
2. **Expansion + GRR ≠ NRR exactly.** Contraction below the t0 floor is absorbed by GRR, not reflected in expansion. The two will land close to NRR but can drift a few points apart for cohorts with heavy down-sell.

## When NOT to use expansion_rate
- All-sources growth including new logos → use `nrr`
- Pure new-logo contribution → use `new_arr`

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly.
