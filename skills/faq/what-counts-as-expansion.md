---
category: faq
owner: gtm-analytics@example.com
confidence_tier: stable
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: on_change
related_skills: [expansion-rate, nrr, new-arr]
---

# What counts as expansion?

**Expansion** = any increase in an existing account's ARR between two months, as detected by `fct_mrr_movement.movement_type = 'expansion'`.

## Yes, counts as expansion

- **Seat adds.** Account at 1 seat × $200/mo → 2 seats × $200/mo = +$2,400 ARR expansion.
- **Plan upgrades.** Starter → Pro, Pro → Enterprise.
- **Contractual price increases** on renewal, agreed to by the customer.

## No, does not count as expansion

- **Brand-new logo.** Classifies as `new`, not expansion. New account = cohort of 1.
- **Reactivation** (churned-then-returned). Day 3 collapses these into `new`; Day 4+ will separate.
- **Trial-to-paid conversion.** The trialing period doesn't carry MRR, so the first `active` period is `new`, not expansion.

## Day 3 limitation

The current `movement_type` doesn't distinguish between **seat-expansion** (CS-led motion) and **plan-upgrade** (AE-led motion). Many GTM orgs track these separately. Day 4+ will add a `property_expansion_subtype` column on `fct_mrr_movement` sourced from the subscription event properties.

## Related gotcha

A plan price change that bulk-updates `unit_amount_cents` on `stg_stripe__subscriptions` can silently shift ARR without producing a movement row. The `assert_mrr_movement_reconciles` singular test (Day 4+) catches this.
