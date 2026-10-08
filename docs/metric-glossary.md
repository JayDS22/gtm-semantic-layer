# Metric Glossary

The 23 public metrics in this project, grouped by domain. Formulas are
sketches, the authoritative definitions live in `models/semantic/*.yml`
and the user-facing explanations live in `skills/metrics/<id>.md`.

Confidence tiers reflect the labels on the skill files themselves:

- **stable**, formula and grain are locked, warehouse inputs are
  trustworthy, metric has been audited against at least one real-world
  reference calculation.
- **evolving**, formula is correct in principle but a known
  simplification is in flight (proxy join, missing dimension, blended
  where segment-weighted is better).
- **draft**, ships but is explicitly partial; see the metric's skill
  file for the known gap and the Day 4+ upgrade path.

## Revenue

| Metric | Formula sketch | Semantic model | Grain | Key dimensions | Confidence | Skill file |
|---|---|---|---|---|---|---|
| `arr` | Cumulative sum of `arr_delta_cents` from start of time, ÷100 | `mrr_movement` | account × month | movement_type, account_sk | stable | `skills/metrics/arr.md` |
| `mrr` | `arr / 12` | `mrr_movement` | account × month | same as arr | stable | `skills/metrics/mrr.md` |
| `new_arr` | Σ `arr_delta_cents` where `movement_type = 'new'` | `mrr_movement` | account × month | movement_type | stable | `skills/metrics/new-arr.md` |
| `net_new_arr` | `new_arr + expansion_arr + contraction_arr + churn_arr` | `mrr_movement` | account × month | movement_type | stable | `skills/metrics/net-new-arr.md` |
| `grr` | `cohort_retained_arr / cohort_t0_arr` (retained = min(curr, t0) per account) | `cohort_arr` | cohort_month × reporting_month | cohort_month | stable | `skills/metrics/grr.md` |
| `nrr` | `cohort_now_arr / cohort_t0_arr` (cohort-static) | `cohort_arr` | cohort_month × reporting_month | cohort_month, segment, region, plan | stable | `skills/metrics/nrr.md` |
| `arr_qoq_annualized_growth_pct` | `(1 + (ARR_q − ARR_{q-1}) / ARR_{q-1})^4 − 1` (QoQ-annualized; see skill for the YoY tradeoff) | `arr_growth` | quarter | metric_time__quarter | stable | `skills/metrics/arr-qoq-growth-pct.md` |

## Pipeline

| Metric | Formula sketch | Semantic model | Grain | Key dimensions | Confidence | Skill file |
|---|---|---|---|---|---|---|
| `pipeline_coverage` | `open_pipeline_arr / quota_arr` (strict) | `quota` + `opportunity` | team × quarter | owner_team | stable | `skills/metrics/pipeline-coverage.md` |
| `pipeline_coverage_qtd` | `(open_pipeline_arr + closed_won_in_period) / quota_arr` | `quota` + `opportunity` | team × quarter | owner_team | stable | `skills/metrics/pipeline-coverage-qtd.md` |
| `win_rate` | `won_opps / closed_opps` | `opportunity` | team × close_date (default quarter) | owner_team, stage | stable | `skills/metrics/win-rate.md` |
| `avg_sales_cycle_days` | `Σ cycle_days / count(closed opps with non-null cycle)` | `opportunity` | team × close_date | owner_team, stage | stable | `skills/metrics/avg-sales-cycle-days.md` |
| `weighted_pipeline_arr` | `Σ (arr_cents × stage_probability)` ÷100 | `opportunity` | team × close_date | stage, owner_team | stable | `skills/metrics/weighted-pipeline-arr.md` |

## Funnel

| Metric | Formula sketch | Semantic model | Grain | Key dimensions | Confidence | Skill file |
|---|---|---|---|---|---|---|
| `mql_to_sql_conv` | `funnel_sqls / funnel_mqls` (same-period proxy) | `funnel_event` | event_date | funnel_stage, account_sk | evolving | `skills/metrics/mql-to-sql-conv.md` |
| `sql_to_won_conv` | `funnel_wons / funnel_sqls` (expansion-event proxy for wons) | `funnel_event` | event_date | funnel_stage | evolving | `skills/metrics/sql-to-won-conv.md` |
| `mql_to_won_conv` | `funnel_wons / funnel_mqls` (same proxy) | `funnel_event` | event_date | funnel_stage | evolving | `skills/metrics/mql-to-won-conv.md` |
| `activation_rate` | `funnel_activations / funnel_signups` | `funnel_event` | event_date | funnel_stage | evolving | `skills/metrics/activation-rate.md` |

## Retention

| Metric | Formula sketch | Semantic model | Grain | Key dimensions | Confidence | Skill file |
|---|---|---|---|---|---|---|
| `expansion_rate` | `cohort_expansion_arr / cohort_t0_arr` (above-t0 portion) | `cohort_arr` | cohort_month × reporting_month | cohort_month, segment | stable | `skills/metrics/expansion-rate.md` |
| `logo_retention` | `cohort_logo_now_count / cohort_logo_t0_count` | `cohort_arr` | cohort_month × reporting_month | cohort_month | stable | `skills/metrics/logo-retention.md` |

## Efficiency

| Metric | Formula sketch | Semantic model | Grain | Key dimensions | Confidence | Skill file |
|---|---|---|---|---|---|---|
| `cac_payback_months` | `12 × sm_spend / sum(new_arr_s × gm_s × mix_s across segments)` (segment-weighted, real new_arr by segment) | `financials` + `mrr_movement` + `segment_margins` seed | quarter |, | stable | `skills/metrics/cac-payback-months.md` |
| `magic_number` | `net_new_arr × 4 / sm_spend` (same-period; textbook lags S&M by one quarter) | `financials` + `mrr_movement` | quarter |, | evolving | `skills/metrics/magic-number.md` |
| `burn_multiple` | `net_burn / net_new_arr` | `financials` + `mrr_movement` | quarter |, | evolving | `skills/metrics/burn-multiple.md` |
| `gross_margin` | `(revenue − cogs) / revenue` | `financials` | quarter |, | stable | `skills/metrics/gross-margin.md` |
| `rule_of_40` | `(arr_qoq_annualized_growth_pct + operating_margin_pct) × 100` (growth + margin) | `financials` + `arr_growth` | quarter |, | stable | `skills/metrics/rule-of-40.md` |

## Note on the 23 public / ~30 supporting split

The semantic layer defines roughly 50 metrics. Only 22 of them get skill
files and show up in this glossary. The rest are **supporting metrics** , 
measures and simple roll-ups like `new_arr_cents`, `cohort_now_arr`,
`cohort_t0_arr`, `cohort_retained_arr`, `won_opps`, `closed_opps`,
`open_pipeline_arr`, `qtd_pipeline_arr`, `cycle_days_total`, `sm_spend`,
`revenue`, `cogs`, `net_burn`, `gross_profit`, etc. These exist to be
composed into derived and ratio metrics (every public ratio needs a
numerator and denominator), and they are legitimate MetricFlow queries,
but exposing them as top-level glossary entries would create noise. A
GTM user asking "what's our pipeline?" wants `pipeline_coverage` or
`weighted_pipeline_arr`, not a choice between seven near-synonymous
`*_pipeline_arr_cents` measures. The crosswalk CI check
(`scripts/skill_metric_crosswalk.py`) is deliberately orphan-only so
supporting metrics can exist without being forced to carry a skill
file they don't earn.
