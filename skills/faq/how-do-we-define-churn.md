---
category: faq
owner: gtm-analytics@example.com
confidence_tier: stable
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: on_change
related_skills: [nrr, grr, logo-retention, what-counts-as-expansion]
---

# How do we define churn?

**Churn** = an account's `curr_arr_cents` fell to 0 in `fct_mrr_movement`. In practice: the account's last `active` or `past_due` subscription moved to `canceled` status in Stripe.

## The specific SQL definition

In `int_subscription_mrr_daily`, we only densify days where `status in ('active', 'past_due')`. The moment the final subscription on an account flips to `canceled`, no row is written for that account from that day on. `fct_mrr_movement` then detects `prev_arr_cents > 0 and curr_arr_cents = 0` → `movement_type = 'churn'`.

## Not churn (yet)

- **past_due.** Still counts as paying for MRR purposes. If the account's status eventually flips to `canceled`, that transition is when it churns.
- **trialing.** Was never paying; cancellation of a trial is not churn, there's just no `new` yet.
- **Downgrade to a cheaper plan.** That's `contraction`, not churn.
- **Downgrade to zero-dollar plan.** Edge case — our seeds don't have one; policy decision is churn, pending Day 4+ when a `is_free_plan` flag lands.

## Reactivation

An account that churned and came back is **reactivation**, not new. Day 3's classifier collapses this into `new`; Day 4+ adds explicit prior-non-zero-history detection.

## Grace period

None, by current policy. If finance wants a 30-day grace window before churn attribution, it belongs in `int_subscription_mrr_daily` (keep `canceled` status in densification for N days post-cancel date).
