---
metric_id: activation_rate
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [segment, plan, cohort_week]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [mql-to-sql-conv, logo-retention]
---

# Activation Rate

## One-liner
Share of signed-up users who hit their first activation milestone (first_query by default). The "did they get value?" metric — the earliest leading indicator of retention and expansion.

## Formula
`funnel_activations / funnel_signups`

## Dimensions you can slice by
- `segment` — SMB / mid-market / enterprise
- `plan` — plan tier at signup
- `cohort_week` — week the user signed up

## How to query
`mf query --metrics activation_rate --group-by metric_time__week`

## Gotchas
1. **Activation milestone is configurable.** We hardcode `first_query` in `product_events`; the activation definition should match whatever your product's aha-moment is. Different definitions produce wildly different rates — pick one deliberately and stick with it.
2. **Time-to-activation is collapsed.** Users who activate on day 1 and users who activate on day 30 both count the same here. Time-to-activation is a separate metric when you need it.

## When NOT to use activation_rate
- Time-to-activation → separate metric (not shipped)
- Dollar-weighted onboarding → use `expansion_rate`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly.
