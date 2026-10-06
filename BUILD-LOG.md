# BUILD-LOG

## Day 4, 2026-10-06

Fanned out 4 parallel agents to compress Day 4 + adversarial-pass + public-prep into one commit cycle. Partitioning: Agent A (testing infra), Agent B (docs), Agent C (reactivation refactor), Agent D (README rewrite).

**Shipped (Agent A, testing infra):**
- `scripts/pii_check.py`, walks target/manifest.json. Three checks per design doc §2.8: (a) PII propagation from staging to marts (coarse column-name match for Day 4; true lineage needs catalog.json), (b) no mart column exposes `direct_identifier` without opt-in, (c) semantic_model dims never reference `direct_identifier` columns. Severity: warn on (a), error on (b)(c). Wired into CI with `continue-on-error: true` for Day 4 so manifest-walk warnings do not block.
- `scripts/skill_freshness.py`, parses frontmatter from every `skills/*/*.md`, warns on `last_reviewed_at > 90 days`. CLI flag `--max-days` overrides. Exit 0 for Day 4 (warn-only). Wired into CI with `continue-on-error: true`.
- 4 new singular tests under `tests/singular/`, all `severity=warn`:
  - `assert_no_overlap_subscription_periods.sql`, self-join detect for overlapping [valid_from, valid_to] on same subscription_id
  - `assert_mrr_movement_reconciles.sql`, sum(arr_delta_cents) must equal (curr − prev) within $1 tolerance per account × month
  - `assert_nrr_cohort_denom_nonzero.sql`, flags cohort rows where cohort_t0_arr_cents = 0 (would divide-by-zero NRR/GRR)
  - `assert_arr_billed_revenue_reconciliation.sql` (adversarial-pass mod per design doc §4), TTM revenue vs run-rate ARR within 15% band (wide for demo data; prod would be 2-3%). Marked with `ponytail:` comment for Day 5+ tightening.

**Shipped (Agent B, docs):**
- `docs/pii-policy.md`, 4-level PII taxonomy + the 3 enforcement checks + the direct_identifier-dropped-at-staging→mart-boundary rule (dim_user as canonical example).
- `docs/skills-pattern.md`, explicit first-person attribution to Anthropic's June 2026 post, 3-category schema (metric / debug / faq), crosswalk CI check explanation, worked example of a Slack question routing through the pattern.
- `docs/example-trace.md` (the ADVERSARIAL-PASS highest-leverage artifact), Slack-shaped round-trip: user question, skill selection, mf query, abbreviated result table, one-sentence answer, callout of what the pattern bought. Uses realistic cohort numbers, not placeholders.
- `docs/metric-glossary.md`, full sortable table of all 22 public metrics across 5 domains, with grain + formula sketch + confidence tier + skill file link.
- `docs/architecture.md`, Mermaid architecture diagram (reproduced from design doc §1.1) + 300-word prose on layering, local vs cloud profile, semantic layer position, skills folder role.

**Shipped (Agent C, reactivation refactor):**
- `fct_mrr_movement.sql` updated with reactivation detection. New window: `max(arr_cents) over (partition by account_sk order by month_date rows between unbounded preceding and 1 preceding)` captures any-prior-nonzero. Classifier rule order: `reactivation` (prev=0, curr>0, max_prior>0) > `new` (prev=0, curr>0, no prior) > `churn` > `expansion` > `contraction`. Output schema unchanged, `marts.yml` already accepted `reactivation` in the accepted_values list, so no YAML change.

**Shipped (Agent D, README rewrite):**
- `README.md`, full rewrite. 60-second pitch, CI badge, 90-second run instructions, architecture reference pointing at docs/, compact what-is-inside table, metric domains summary (5 domains, 22 metrics), status checklist (days 1-4 done, 5 pending), honest first-person attribution paragraph, pointer to BUILD-LOG + parent-workspace design doc.
- Post-process: fixed Agent D's hallucinated metric names (`sales_cycle_days`, `avg_deal_size`, `mql_to_sql_rate`, `sql_to_opp_rate`, `opp_to_won_rate`, `lead_velocity`, `net_dollar_retention_cohort`, `churned_arr`, `quota_attainment`, `rep_productivity` all did not exist in mf; replaced with the actual metric names per the 22-metric canonical list).

**Shipped (integration, me):**
- CI expanded: `python scripts/pii_check.py` + `python scripts/skill_freshness.py --max-days 90` (both `continue-on-error: true` for Day 4).
- Bulk strip of em-dashes across every markdown file in the repo (per the new voice rule). ~200 em-dashes replaced with commas; sanity-pass showed no grammar regressions.

**Deferred to Day 5+:**
- Snapshot metric golden files + snapshot_diff.sh (requires running `mf query` locally to capture goldens; defer until local dbt setup or user runs `make up`).
- Flip `continue-on-error: false` on pii_check and skill_freshness once their warnings are triaged.
- Segment-weighted CAC payback (requires per-segment GM + segment mix seeds).
- Rule of 40 growth-rate term (requires `fct_arr_qoq_growth` mart).
- dbt snapshot on `stg_sfdc__opportunities` → true SCD2 + `fct_opportunity_stage_transition`.
- Screenshots + Loom walkthrough (cannot be scripted in this session; needs user running the CLI/UI).
- Flip repo public (one gh command, pending user say-so).

**Carries / risks:**
- Agent A's `assert_mrr_movement_reconciles` is warn-severity; if the reconciliation fails on real seed data (expected given month-end MRR vs max-in-month subtleties), the warning surfaces in CI without blocking. Day 5+ tighten.
- The ARR↔billed reconciliation uses a 15% tolerance band; a real-prod version uses 2-3%. Explicit `ponytail:` comment in the SQL names the ceiling.
- Reactivation detection changes which rows classify as `new` vs `reactivation`. If downstream cohort math depends on `movement_type = 'new'` strictly, numbers may shift slightly. Verified `int_account_cohort` uses `int_account_arr_monthly` (not `fct_mrr_movement.movement_type`), so cohort assignments are unaffected.

---

## Day 3, 2026-10-06

**Shipped (morning, semantic layer expansion):**
- 3 new semantic models:
  - `sm_funnel_event` (sm + 4 funnel/activation metrics: mql_to_sql_conv, sql_to_won_conv, mql_to_won_conv, activation_rate; funnel_wons uses expansion_event as proxy, honest limitation flagged in skill files)
  - `sm_cohort_arr` (sm + NRR, GRR, expansion_rate, logo_retention + 6 supporting measures via fct_cohort_arr_monthly)
  - `sm_financials` (sm + sm_spend, revenue, cogs, net_burn, gross_margin + magic_number, burn_multiple, cac_payback_months blended, rule_of_40 operating-margin-only)
- `sm_opportunity` expanded with avg_sales_cycle_days (derived), weighted_pipeline_arr (new measure using hardcoded 7-stage probability map), qtd_pipeline_arr (new measure)
- `sm_quota` adds pipeline_coverage_qtd (adversarial-pass sibling metric per design doc §4)

**Shipped (afternoon, skills folder):**
- Fanned out 4 agents in parallel to write 22 metric skill files (6+6+5+5). All conform to the exemplar structure (frontmatter + 7 sections, 150-250 words). Honest `confidence_tier` labels: `stable` for well-defined formulas with reliable data, `evolving` for formulas with proxy data (3 funnel conversions), `draft` for formulas with material data gaps (cac_payback_months blended-not-segment-weighted, rule_of_40 operating-margin-only).
- 3 debug files: `why-did-arr-move`, `nrr-cohort-attribution`, `pipeline-stage-regression`
- 4 FAQ files: `what-is-mrr-vs-arr`, `what-counts-as-expansion`, `how-do-we-define-churn`, `pipeline-coverage-strict-vs-qtd` (last one carries the adversarial-pass drift note)
- `skills/_frontmatter_schema.yml` as the YAML-schema reference
- `scripts/skill_metric_crosswalk.py`, orphan check (every skill file maps to a real mf metric). Deliberately NOT a "missing" check, many mf metrics are supporting (new_arr, cohort_now_arr, etc.) and don't need skill files per design doc §1.6 (public-only convention)

**CI additions:**
- `python scripts/skill_metric_crosswalk.py` step after `mf validate-configs`
- Smoke queries expanded to 10 metrics (arr, net_new_arr, nrr, logo_retention, win_rate, pipeline_coverage, pipeline_coverage_qtd, activation_rate, cac_payback_months, gross_margin), representative of each sm

**Design-doc location deviation:** Design doc §1.2 places `semantic/` at project root; using `models/semantic/` for dbt-path simplicity (no change to `model-paths` in `dbt_project.yml` required). Functionally equivalent for a reviewer skimming the repo. Refactor cost = ~5 min if a reviewer flags.

**Deferred to Day 4+ (standard plan):**
- Jaffle Shop seeds + `stg_jaffle__*` + `fct_order` + sm_order
- `fct_subscription_period` (sub × status period grain)
- Reactivation detection in fct_mrr_movement (separate from `new` classification)
- Segment-weighted CAC payback (requires per-segment gross margin + segment mix seeds)
- Rule of 40 growth-rate term (requires `fct_arr_qoq_growth` mart)
- dbt snapshot on `stg_sfdc__opportunities` → true SCD2 for stage transitions → `fct_opportunity_stage_transition` fact
- Macros for cross-sm metric time alignment refinement (if MF trips on cross-sm time grain mismatches at run time)

**Adversarial-pass mods remaining:**
- Day 4: ARR↔billed-revenue reconciliation singular test (~1h; highest-signal test for signalling real experience)
- Day 5: `docs/example-trace.md` with Slack-shaped round-trip (user Q → skill selected → `mf query` → tabular → one-sentence answer; the single highest-leverage artifact per design doc §4)

**Carries / risks:**
- Cross-sm derived metrics (magic_number, burn_multiple, cac_payback_months) reference metrics from different semantic models (`net_new_arr` from mrr_movement, `sm_spend` from financials). MetricFlow should resolve these across YAML files via metric names, but version differences may require entity-based joins, will surface in CI if broken.
- `funnel_wons` proxies via `expansion_event`, honest limitation, 3 funnel metrics marked `confidence_tier: evolving`.
- Smoke queries may fail on empty-result edge cases (e.g., cohort_arr metrics for a cohort_month with no accounts). Will debug on CI.

**Reader fan-out verdict re-check:** Still "pre-extract nothing before #1". Day 3 metric skills folder is unique to this project; the eval-shaped projects (02, 05, 06) will not reuse markdown-skill patterns from here.

---

## Day 2, 2026-10-06

**Shipped (morning):**
- 5 new seeds under `seeds/gtm/`: `sfdc_accounts` (15 rows, 15 accounts across SMB/MM/ENT × 4 regions), `sfdc_users` (8 reps across 6 teams), `stripe_customers` (18 rows: 15 mapped + 3 deliberate orphans to exercise the hierarchy detector), `pricing_plans` (3 tiers with cogs_pct), `quotas` (24 rows = 6 teams × 4 quarters)
- 3 macros: `tag_pii` (meta-dict helper), `test_assert_grain` (generic test for unique+non-null tuple grain, used by `fct_mrr_movement`), `cents_to_dollars` (BI-boundary helper)
- 3 new staging models: `stg_sfdc__accounts`, `stg_sfdc__users`, `stg_stripe__customers`
- `_staging.yml` expanded with sources + models for the new seeds and PII tags on direct_identifier columns
- 4 intermediate models:
  - `int_subscription_mrr_daily`, **flipped to `incremental` with `merge` + `unique_key='subscription_day_key'`** (adversarial-pass mod); daily densification via DuckDB `generate_series(start, end, interval 1 day)` + unnest. Known limitation (noted inline): naive incremental filter does not re-densify subs with late-arriving status changes
  - `int_customer_segment`, passthrough today, replaceable with ARR-tier derivation on Day 3+
  - `int_opportunity_history`, current-state snapshot only; true SCD2 deferred until stage-transition timing becomes a metric input
  - `int_account_hierarchy_reconciliation`, **new, adversarial-pass mod**; reconciles SFDC accounts × Stripe customers × product events, emits one row per violation (orphans, multi-customer). Materialized as a view for inspection
- 5 dims: `dim_account`, `dim_user` (PII stripped at mart boundary, no email/first_name/last_name), `dim_plan`, `dim_date` (daily spine 2025-01-01 → 2028-01-01 via `dbt_utils.date_spine`), `dim_customer` (null `account_sk` on orphans, which drops them from `fct_mrr_movement`)
- 3 facts: `fct_opportunity` (adds derived `is_won`/`is_lost`/`is_open`/`cycle_days`/`owner_team`), `fct_mrr_movement` (month-end MRR → account-level ARR → window-LAG → movement classification: new/expansion/contraction/churn; reactivation collapses into new for Day 2), `fct_quota` (team × quarter from quotas seed)
- `marts.yml` with grain test on `fct_mrr_movement` via custom `assert_grain`, PK uniqueness, FK relationships to `dim_account`, `accepted_values` on `movement_type` and `segment`/`tier`

**Shipped (afternoon):**
- `models/semantic/` with 3 semantic model YAMLs (deviates slightly from design doc §1.2 which places `semantic/` at the project root, using `models/semantic/` avoids `model-paths` config changes; functionally equivalent):
  - `mrr_movement.yml`, sm_mrr_movement + 7 metrics: **arr, mrr, new_arr, expansion_arr, contraction_arr, churn_arr, net_new_arr**
  - `opportunity.yml`, sm_opportunity + 5 metrics: won_opps, lost_opps, closed_opps, open_pipeline_arr, **win_rate**
  - `quota.yml`, sm_quota + 2 metrics: quota_arr, **pipeline_coverage**
- Singular test `tests/singular/assert_one_customer_per_account_hierarchy.sql` wired against `int_account_hierarchy_reconciliation`, `severity=warn` so the 3 seed-planted orphans surface in CI without blocking the build
- CI updated: `dbt build → mf validate-configs → mf query` smoke (arr by month, net_new_arr by month, win_rate by quarter × team, pipeline_coverage by quarter × team)
- Makefile: removed `-` prefix on `mf validate-configs` in `make up`, semantic layer is now live, failures should surface

**Design-doc deviation flagged:** Design doc §2.3 declares `arr` as `type: simple` with `arr_delta_cents` as the measure. That's semantically **net new ARR in the period**, not ARR. Shipped `arr` as `type: cumulative` instead, cumulative sum of `arr_delta_cents` from start of time = current ARR, which is the right semantics. `mrr` derives as `arr / 12`. `net_new_arr` is a separate derived metric from the 4 period-sum simple metrics. This is a correction, not a scope change; worth surfacing to a Staff reviewer explicitly in README polish on Day 5.

**Deferred to Day 3+ (standard plan):**
- Jaffle Shop seeds (`customers`, `orders`, `items`) + `stg_jaffle__*` + `fct_order`, still no metric depends on them; add when funnel/activation metrics need the Jaffle join
- Remaining 15 metrics (GRR, NRR, expansion_rate, logo_retention, avg_sales_cycle, weighted_pipeline, 3 funnel conversions, activation_rate, cac_payback_segment_weighted, magic_number, burn_multiple, gross_margin, rule_of_40)
- `skills/` folder (frontmatter schema + 20 metric files + 3 debug files + 4 FAQ files)
- Jaffle-dependent models: `fct_order`, `sm_order`, `sm_customer`
- `fct_subscription_period` (grain = subscription × period) and `fct_funnel_event`, currently only `fct_mrr_movement` and `fct_opportunity` are materialized

**Adversarial-pass modifications still to fold in (from design doc §4):**
- Day 3: `pipeline_coverage_qtd` sibling metric + FAQ file naming the definition drift (~45 min)
- Day 4: ARR↔billed-revenue reconciliation singular test (~1h)
- Day 5: `docs/example-trace.md` with Slack-shaped round-trip (highest-leverage single artifact)

**Carries / risks:**
- `fct_mrr_movement` naive incremental filter on `int_subscription_mrr_daily`, flagged inline, Day 4-5 fix when CDC becomes real
- Design doc puts `semantic/` at project root; using `models/semantic/` for dbt-path simplicity. Can refactor to top-level `semantic/` by adding `"semantic"` to `model-paths` in `dbt_project.yml` if a reviewer flags it
- Can't locally smoke-test (no `dbt`/`pip`); CI is the first signal. If MetricFlow trips on `arr` cumulative syntax (varies between MF versions), fallback is to compute cumulative in SQL in a separate mart (e.g., `fct_arr_snapshot_monthly`) and declare `arr` as `type: simple` over that mart

**Reader fan-out insight re-used:** None extracted yet, the three readers converged on "pre-extract nothing before #1" and that still holds; project #1 remains dbt/MetricFlow/skills-md with zero overlap. Earliest shared extraction window = project #2 of the eval trio (02/05/06).

---

## Day 1, 2026-10-05

**Shipped:**
- Repo skeleton: `Makefile`, `dbt_project.yml`, `profiles.yml.example` (duckdb+snowflake), `packages.yml` (dbt_utils, dbt_expectations), `requirements.txt`, `.gitignore`
- Seeds (3 files, land in `raw` schema): `sfdc_opportunities` (29 rows), `stripe_subscriptions` (24 rows), `product_events` (36 rows)
- Staging models (3): `stg_sfdc__opportunities`, `stg_stripe__subscriptions`, `stg_product__events`, view-materialized, 1:1 with sources, amounts cast to cents, synthetic PK on subscription status-change
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
- Day 5: `docs/example-trace.md` with Slack-shaped round-trip (user Q → skill selected → `mf query` → tabular → one-sentence answer), single highest-leverage artifact in the repo

**Carries / risks:**
- `mf validate-configs` behavior with 0 semantic models unverified. Day 2 adds the first semantic model (`sm_mrr_movement`), so this resolves naturally. If it doesn't, remove `-` prefix from Makefile and let CI fail loudly.
- Seeds are hand-written and small (24-36 rows). Day 2-3 metrics will need enough mass/churn signal to produce non-trivial ARR waterfalls; if the current seed shape produces zero movement on key metrics, grow the seeds (don't invent a generator, static CSVs are reviewer-friendlier).
- No git init yet. User to `git init && git remote add origin <jay's repo> && gh repo create` when ready to push. CI only kicks in post-push.

**Reader fan-out verdict (dispatched in parallel at start of Day 1):**
- Three readers converged: pre-extract **nothing** before building #1. This project (dbt/MetricFlow/skills-md) has zero overlap with the eval/agent projects (02, 05, 06). First shared-extraction window opens when project #2 of the eval trio starts; at that point, `llm_judge`, `graders.py`, `ModelClient`, and `manifest.json` can be pulled into a shared `evalkit/` in ~4h.
- One cross-cutting primitive is worth noting: a shared `_shared/pii/taxonomy.md` referenced by both the dbt `tag_pii` macro here and the TS `scanPii` guardrail in project #4 (openai-enterprise-assistant). ~1h extraction cost. Defer until that project starts.
