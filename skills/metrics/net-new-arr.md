---
metric_id: net_new_arr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [segment, region]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [new-arr, magic-number, burn-multiple]
---

# Net New ARR, Period Change in ARR

## One-liner
Net change in ARR over the period, the single number that answers "did we grow this month?" after netting new business, expansion, contraction, and churn.

## Formula
`net_new_arr = new_arr + expansion_arr + contraction_arr + churn_arr`

Contraction and churn are stored as SIGNED NEGATIVE values in `fct_mrr_movement`, so the formula is a straight sum, not a mixed add/subtract.

## Dimensions you can slice by
- `segment`, SMB / MM / ENT
- `region`, NAMER / EMEA / APAC / LATAM

## How to query
`mf query --metrics net_new_arr --group-by metric_time__month`

## Gotchas
1. **Signed components are load-bearing.** This metric is derived, so the sign comes from each component. If contraction or churn ever ships as a positive magnitude in the fact table, `net_new_arr` double-subtracts and understates growth. The staging test `assert_churn_contraction_negative` guards this.
2. **Board-deck phrasing confusion.** Decks often write "+$X new, -$Y churn" and expect readers to subtract. `net_new_arr` already IS the net, do not subtract churn again on top.

## When NOT to use net_new_arr
- Brand-new-logo signal only → `new_arr`
- Growth-rate / efficiency framing → `magic_number`
- Burn-adjusted growth quality → `burn_multiple`

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly on the first business day.
