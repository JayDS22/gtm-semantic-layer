---
category: debug
owner: gtm-analytics@example.com
confidence_tier: stable
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [nrr, grr, expansion-rate, logo-retention]
---

# NRR cohort attribution

NRR is cohort-static. If this fact surprises you, this runbook will unsurprise you.

## The one rule

A cohort = all accounts whose **first-paid month** equals month `t0`. That set of accounts never changes. New logos acquired after `t0` do NOT backfill into any prior cohort's NRR.

## What this means in practice

- Q3 NRR going up could mean cohorts are expanding, OR it could mean the stronger-expansion cohorts are weighted more heavily in the aggregate.
- A late-stage churn in a 2023 cohort hurts the 2023 cohort's NRR forever, even in reporting months years later.
- Reporting NRR without the `cohort_month` dim risks hiding bimodal cohort behavior (one cohort doing great, another dying).

## Diagnostic query

```
mf query \
  --metrics nrr,grr,expansion_rate,logo_retention \
  --group-by metric_time__month,cohort_arr__cohort_month
```

## When blended NRR goes up but every cohort looks flat

Aggregate NRR = weighted average of cohort NRRs, where weights are each cohort's `cohort_t0_arr`. If an older large-ARR cohort rolls off the reporting window, aggregate NRR shifts without any individual cohort changing.

## Partial-month cohort rule

Accounts first-paid on 2026-07-15 land in the July cohort (first-paid-month rule), not August. If someone asks "why did July NRR go up", confirm the cohort size didn't shift due to mid-month boundary cases.

## Owner, update cadence

Owned by GTM Analytics. Reviewed quarterly.
