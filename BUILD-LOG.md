# BUILD-LOG

## Day 2 — 2026-10-06

**Shipped (morning):**
- 5 new seeds under `seeds/gtm/`: `sfdc_accounts` (15 rows, 15 accounts across SMB/MM/ENT × 4 regions), `sfdc_users` (8 reps across 6 teams), `stripe_customers` (18 rows: 15 mapped + 3 deliberate orphans to exercise the hierarchy detector), `pricing_plans` (3 tiers with cogs_pct), `quotas` (24 rows = 6 teams × 4 quarters)
- 3 macros: `tag_pii` (meta-dict helper), `test_assert_grain` (generic test for unique+non-null tuple grain, used by `fct_mrr_movement`), `cents_to_dollars` (BI-boundary helper)
- 3 new staging models: `stg_sfdc__accounts`, `stg_sfdc__users`, `stg_stripe__customers`
- `_staging.yml` expanded with sources + models for the new seeds and PII tags on direct_identifier columns
- 4 intermediate models:
  - `int_subscription_mrr_daily` — **flipped to `incremental` with `merge` + `unique_key='subscription_day_key'`** (adversarial-pass mod); daily densification via DuckDB `generate_series(start, end, interval 1 day)` + unnest. Known limitation (noted inline): naive incremental filter does not re-densify subs with late-arriving status changes
  - `int_customer_segment` — passthrough today, replaceable with ARR-tier derivation on Day 3+
  - `int_opportunity_history` — current-state snapshot only; true SCD2 deferred until stage-transition timing becomes a metric input
  - `int_account_hierarchy_reconciliation` — **new, adversarial-pass mod**; reconciles SFDC accounts × Stripe customers × product events, emits one row per violation (orphans, multi-customer). Materialized as a view for inspection
- 5 dims: `dim_account`, `dim_user` (PII stripped at mart boundary — no email/first_name/last_name), `dim_plan`, `dim_date` (daily spine 2025-01-01 → 2028-01-01 via `dbt_utils.date_spine`), `dim_customer` (null `account_sk` on orphans, which drops them from `fct_mrr_movement`)
- 3 facts: `fct_opportunity` (adds derived `is_won`/`is_lost`/`is_open`/`cycle_days`/`owner_team`), `fct_mrr_movement` (month-end MRR → account-level ARR → window-LAG → movement classification: new/expansion/contraction/churn; reactivation collapses into new for Day 2), `fct_quota` (team × quarter from quotas seed)
- `marts.yml` with grain test on `fct_mrr_movement` via custom `assert_grain`, PK uniqueness, FK relationships to `dim_account`, `accepted_values` on `movement_type` and `segment`/`tier`

**Shipped (afternoon):**
- `models/semantic/` with 3 semantic model YAMLs (deviates slightly from design doc §1.2 which places `semantic/` at the project root — using `models/semantic/` avoids `model-paths` config changes; functionally equivalent):
  - `mrr_movement.yml` — sm_mrr_movement + 7 metrics: **arr, mrr, new_arr, expansion_arr, contraction_arr, churn_arr, net_new_arr**
  - `opportunity.yml` — sm_opportunity + 5 metrics: won_opps, lost_opps, closed_opps, open_pipeline_arr, **win_rate**
  - `quota.yml` — sm_quota + 2 metrics: quota_arr, **pipeline_coverage**
- Singular test `tests/singular/assert_one_customer_per_account_hierarchy.sql` wired against `int_account_hierarchy_reconciliation`, `severity=warn` so the 3 seed-planted orphans surface in CI without blocking the build
- CI updated: `dbt build → mf validate-configs → mf query` smoke (arr by month, net_new_arr by month, win_rate by quarter × team, pipeline_coverage by quarter × team)
- Makefile: removed `-` prefix on `mf validate-configs` in `make up` — semantic layer is now live, failures should surface

**Design-doc deviation flagged:** Design doc §2.3 declares `arr` as `type: simple` with `arr_delta_cents` as the measure. That's semantically **net new ARR in the period**, not ARR. Shipped `arr` as `type: cumulative` instead — cumulative sum of `arr_delta_cents` from start of time = current ARR, which is the right semantics. `mrr` derives as `arr / 12`. `net_new_arr` is a separate derived metric from the 4 period-sum simple metrics. This is a correction, not a scope change; worth surfacing to a Staff reviewer explicitly in README polish on Day 5.

**Deferred to Day 3+ (standard plan):**
- Jaffle Shop seeds (`customers`, `orders`, `items`) + `stg_jaffle__*` + `fct_order` — still no metric depends on them; add when funnel/activation metrics need the Jaffle join
- Remaining 15 metrics (GRR, NRR, expansion_rate, logo_retention, avg_sales_cycle, weighted_pipeline, 3 funnel conversions, activation_rate, cac_payback_segment_weighted, magic_number, burn_multiple, gross_margin, rule_of_40)
- `skills/` folder (frontmatter schema + 20 metric files + 3 debug files + 4 FAQ files)
- Jaffle-dependent models: `fct_order`, `sm_order`, `sm_customer`
- `fct_subscription_period` (grain = subscription × period) and `fct_funnel_event` — currently only `fct_mrr_movement` and `fct_opportunity` are materialized

**Adversarial-pass modifications still to fold in (from design doc §4):**
- Day 3: `pipeline_coverage_qtd` sibling metric + FAQ file naming the definition drift (~45 min)
- Day 4: ARR↔billed-revenue reconciliation singular test (~1h)
- Day 5: `docs/example-trace.md` with Slack-shaped round-trip (highest-leverage single artifact)

**Carries / risks:**
- `fct_mrr_movement` naive incremental filter on `int_subscription_mrr_daily` — flagged inline, Day 4-5 fix when CDC becomes real
- Design doc puts `semantic/` at project root; using `models/semantic/` for dbt-path simplicity. Can refactor to top-level `semantic/` by adding `"semantic"` to `model-paths` in `dbt_project.yml` if a reviewer flags it
- Can't locally smoke-test (no `dbt`/`pip`); CI is the first signal. If MetricFlow trips on `arr` cumulative syntax (varies between MF versions), fallback is to compute cumulative in SQL in a separate mart (e.g., `fct_arr_snapshot_monthly`) and declare `arr` as `type: simple` over that mart

**Reader fan-out insight re-used:** None extracted yet — the three readers converged on "pre-extract nothing before #1" and that still holds; project #1 remains dbt/MetricFlow/skills-md with zero overlap. Earliest shared extraction window = project #2 of the eval trio (02/05/06).

---

## Day 1 — 2026-10-05

**Shipped:**
- Repo skeleton: `Makefile`, `dbt_project.yml`, `profiles.yml.example` (duckdb+snowflake), `packages.yml` (dbt_utils, dbt_expectations), `requirements.txt`, `.gitignore`
- Seeds (3 files, land in `raw` schema): `sfdc_opportunities` (29 rows), `stripe_subscriptions` (24 rows), `product_events` (36 rows)
- Staging models (3): `stg_sfdc__opportunities`, `stg_stripe__subscriptions`, `stg_product__events` — view-materialized, 1:1 with sources, amounts cast to cents, synthetic PK on subscription status-change
- Source + staging YAML with `not_null`/`unique` tests on PKs and `meta.pii` tags on sensitive columns (customer_name, customer_id, user_id)
- GitHub Actions CI: `dbt deps → seed → build → sqlfluff` (sqlfluff soft-fail on Day 1 to avoid rabbit hole)
- README first draft with attribution paragraph
- `BUILD-LOG.md` (this file)

**Deferred to Day 2 (standard plan):**
- Jaffle Shop seeds (customers, orders, items) + `stg_jaffle__*` staging models
- Supporting GTM seeds: `sfdc_accounts`, `sfdc_users`, `stripe_customers`, `stripe_invoices`, `pricing_plans`, `cohorts`
- Intermediate models: `int_subscription_mrr_daily`, `int_opportunity_history`, `int_customer_segment`, `int_funnel_events`
- Mart models: `dim_account`, `dim_customer`, `dim_date`, `dim_plan`, `dim_user`, `fct_opportunity`, `fct_subscription_period`, `fct_mrr_movement`, `fct_funnel_event`
- Macros: `tag_pii`, `assert_grain`, `cents_to_dollars`
- First 5 metrics in MetricFlow YAML: ARR, MRR, net_new_arr, pipeline_coverage, win_rate
- Re-enable `mf validate-configs` in Makefile `up` (currently prefixed with `-` to soft-fail on empty semantic layer)

**Adversarial-pass modifications to fold in (from design doc §4):**
- Day 2: `int_account_hierarchy_reconciliation.sql` + `assert_one_customer_per_account_hierarchy` singular test (~2h; signals awareness of hardest problem in a real GTM layer)
- Day 2: flip `int_subscription_mrr_daily` to `incremental` with `merge` strategy + `unique_key` + visible comment on why (~30 min; signals production awareness)
- Day 3: `pipeline_coverage_qtd` sibling metric + FAQ file naming the definition drift (~45 min)
- Day 4: ARR↔billed-revenue reconciliation singular test (~1h; replaces one lower-value singular test)
- Day 5: `docs/example-trace.md` with Slack-shaped round-trip (user Q → skill selected → `mf query` → tabular → one-sentence answer) — single highest-leverage artifact in the repo

**Carries / risks:**
- `mf validate-configs` behavior with 0 semantic models unverified. Day 2 adds the first semantic model (`sm_mrr_movement`), so this resolves naturally. If it doesn't, remove `-` prefix from Makefile and let CI fail loudly.
- Seeds are hand-written and small (24-36 rows). Day 2-3 metrics will need enough mass/churn signal to produce non-trivial ARR waterfalls; if the current seed shape produces zero movement on key metrics, grow the seeds (don't invent a generator — static CSVs are reviewer-friendlier).
- No git init yet. User to `git init && git remote add origin <jay's repo> && gh repo create` when ready to push. CI only kicks in post-push.

**Reader fan-out verdict (dispatched in parallel at start of Day 1):**
- Three readers converged: pre-extract **nothing** before building #1. This project (dbt/MetricFlow/skills-md) has zero overlap with the eval/agent projects (02, 05, 06). First shared-extraction window opens when project #2 of the eval trio starts; at that point, `llm_judge`, `graders.py`, `ModelClient`, and `manifest.json` can be pulled into a shared `evalkit/` in ~4h.
- One cross-cutting primitive is worth noting: a shared `_shared/pii/taxonomy.md` referenced by both the dbt `tag_pii` macro here and the TS `scanPii` guardrail in project #4 (openai-enterprise-assistant). ~1h extraction cost. Defer until that project starts.
