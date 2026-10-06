---
category: faq
owner: gtm-analytics@example.com
confidence_tier: stable
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: on_change
related_skills: [arr, mrr]
---

# MRR vs ARR

**MRR** = Monthly Recurring Revenue. The subscription revenue we would recognize this month if nothing changed.

**ARR** = MRR × 12. Not "revenue recognized this year", not "bookings". Just a convenience annualization of today's run rate.

## When to use which

- Board / investor conversations → **ARR** (12-month framing)
- Operating / in-month movement → **MRR** (actual month-over-month delta)
- Multi-year contracts → **ARR** with a flag; the annualization is still monthly-based

## What's NOT in MRR

- One-time services / implementation fees
- Overage / usage charges that aren't on a recurring plan
- Discounts outside the plan contract (treat as contra-MRR per policy)

## What IS in MRR

- Monthly plan base price × quantity
- Annual plan base price × quantity ÷ 12 (annualized plans are included at their monthly-equivalent rate)
- Legitimate contractual discounts baked into the plan

## Common mistake

Someone pulls "revenue" from the finance system and compares to ARR. These are different numbers. ARR is a run-rate; revenue is recognized GAAP revenue, multi-year prepaid deals land in ARR instantly but recognize revenue over time.
