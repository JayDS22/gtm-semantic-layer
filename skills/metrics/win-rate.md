---
metric_id: win_rate
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [team, stage, close_date]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: weekly
related_skills: [avg-sales-cycle-days, weighted-pipeline-arr, pipeline-coverage]
---

# Win Rate, Closed-Won / Closed-Total

## One-liner
Share of closed opportunities that ended in Closed Won. Rolled by team × close date (default quarter). Backward-looking, tells you how the team has been converting the deals they've worked, not what's about to close.

## Formula
`won_opps / (won_opps + lost_opps)`

Grouped by `owner_team` and `close_date` (rolled to quarter by default). Only closed opportunities land in the denominator, anything still open is excluded.

## Dimensions you can slice by
- `team`, via `opportunity__owner_team`
- `stage`, filter dimension on `opportunity__stage`
- `close_date`, defaults to quarter grain

## How to query
`mf query --metrics win_rate --group-by metric_time__quarter,opportunity__owner_team`

## Gotchas
1. **Denominator excludes OPEN opps.** Win rate is a lagging metric, not a forecast. If you want "what will we close?", pair this with `pipeline_coverage` or `weighted_pipeline_arr`.
2. **Reopened opps lose their middle history.** An opp that went Closed Lost → Negotiation → Closed Won counts as won in its final close date, but the lost intermediate state is not in `fct_opportunity` (no SCD2 yet, see `int_opportunity_history` for staged future work).

## When NOT to use win_rate
- Forward forecast of close probability → use `pipeline_coverage` or `weighted_pipeline_arr`
- Deal size / sizing analysis → read `arr_cents` from `fct_opportunity`

## Owner, update cadence
Owned by GTM Analytics. Reviewed weekly during the quarter.
