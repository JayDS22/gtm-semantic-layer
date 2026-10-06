---
category: debug
owner: gtm-analytics@example.com
confidence_tier: stable
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [arr, net-new-arr, new-arr, expansion-rate]
---

# Why did ARR move?

ARR delta between any two periods decomposes into exactly five movements: new, expansion, reactivation, contraction, churn. If the question is "why did ARR go up/down", the answer always lives in `fct_mrr_movement`.

## Diagnostic query

```
mf query \
  --metrics new_arr,expansion_arr,contraction_arr,churn_arr \
  --group-by metric_time__month,account__segment \
  --start-time <t0> --end-time <t1>
```

## Reading the output

1. **`new_arr` dominates** → net new logo quarter. Check `pipeline_coverage` for the trailing quarter to see if this was expected.
2. **`expansion_arr` dominates** → existing-base growth. Slice by `account__segment` and look at `expansion_rate` by cohort to see where the growth came from.
3. **`churn_arr` dominates** → logo loss. Pivot to `logo_retention` and `fct_mrr_movement` filtered to `movement_type = 'churn'` to find which accounts churned.
4. **Movements are small in absolute terms but ARR looks big** → check for a plan price change that re-based `unit_amount_cents` without producing a movement row (the `assert_mrr_movement_reconciles` singular test catches this on Day 4+).

## Common pitfalls

- **Reactivation vs new.** An account that churned and came back is reactivation, not new. Day 3's classifier collapses reactivation into 'new'; refined on Day 4+.
- **Mid-month cohort start.** An account that first paid July 15 lands in the July cohort (first-paid-month rule). Do not query by created_at of the SFDC opportunity.

## Owner, update cadence

Owned by GTM Analytics. Reviewed quarterly.
