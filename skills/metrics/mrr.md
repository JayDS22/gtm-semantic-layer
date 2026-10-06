---
metric_id: mrr
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [segment, region, plan]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: monthly
related_skills: [arr, what-is-mrr-vs-arr]
---

# MRR, Monthly Recurring Revenue

## One-liner
Monthly recurring revenue, the subscription revenue we would recognize this month if nothing changed. A run-rate convenience derived directly from ARR.

## Formula
`MRR_t = ARR_t / 12`

MRR is a derived metric. It inherits all cohort, segment, and plan semantics from `arr`.

## Dimensions you can slice by
- `segment`, SMB / MM / ENT (inherited from `arr`)
- `region`, NAMER / EMEA / APAC / LATAM
- `plan`, current plan on the account

## How to query
`mf query --metrics mrr --group-by metric_time__month`

## Gotchas
1. **MRR is NOT GAAP revenue.** It is not "revenue recognized this month." It's a run-rate convenience that excludes one-time services, overages, and usage spikes. Finance will never tie MRR to the general ledger.
2. **Contract shape is invisible here.** Multi-year contracts land in MRR via their monthly equivalent, so a prepaid 36-month contract and a month-to-month contract of equal size produce identical MRR, the cash timing difference is lost.

## When NOT to use MRR
- GAAP revenue reporting → use `revenue` from `sm_financials`
- Annualized board-level framing → use `arr` directly (same signal, cleaner units)
- Usage-based or consumption revenue → MRR excludes it by design

## Owner, update cadence
Owned by GTM Analytics. Reviewed monthly on the first business day, in lockstep with `arr`.
