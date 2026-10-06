---
category: debug
owner: gtm-analytics@example.com
confidence_tier: evolving
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [pipeline-coverage, win-rate, weighted-pipeline-arr]
---

# Pipeline stage regression

Why an opportunity moved backward in stage (Negotiation → Discovery, Proposal → Qualification) and how to detect it in this warehouse.

## The current data limitation

`fct_opportunity` is a **current-state** fact, one row per opp at today's state. `int_opportunity_history` is a passthrough today (not SCD2). This means we **cannot detect stage regressions from this warehouse alone** until the dbt snapshot on `stg_sfdc__opportunities` lands (Day 4+).

Until then, stage regressions must be inferred from SFDC audit history or diff'd between consecutive dbt runs.

## Workaround today

Run `dbt build` on consecutive days, save `fct_opportunity` snapshots externally, diff on `opportunity_id` for `stage` changes. Then join back:

```sql
select
  opportunity_id, snap_yesterday.stage as prev_stage, snap_today.stage as curr_stage,
  array_position(array['Prospecting','Qualification','Discovery','Proposal','Negotiation','Closed Won'], snap_today.stage)
    < array_position(array['Prospecting','Qualification','Discovery','Proposal','Negotiation','Closed Won'], snap_yesterday.stage)
    as is_regression
from snap_today
join snap_yesterday using (opportunity_id)
where snap_today.stage != snap_yesterday.stage
```

## What stage regression typically signals

1. **Over-forecasted deal.** AE walked a Discovery opp into Negotiation to pad commit, finance reality forced it back.
2. **Scope change.** Opp's buying committee or scope changed, resetting earlier qualification.
3. **Hygiene cleanup.** QBR exposed stale advanced-stage opps that should've been de-staged weeks ago.

## When the Day 4+ SCD2 lands

`int_opportunity_history` with `dbt_valid_from`/`dbt_valid_to` + a `fct_opportunity_stage_transition` fact at grain `opp × transition` will make this a one-query answer.

## Owner, update cadence

Owned by GTM Analytics. Reviewed quarterly.
