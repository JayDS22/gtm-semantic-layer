# Example Trace: Slack → Skill → MetricFlow → Answer

This is the single highest-leverage artifact in the repo. It shows the full
round-trip of a Slack-tagged assistant query, grounded in the actual skill
files and semantic models in this project.

### User (Slack)

> @claude why is NRR down this quarter?

### Assistant: skill selection

Loading `skills/metrics/nrr.md` + `skills/debug/nrr-cohort-attribution.md`
+ `skills/metrics/expansion-rate.md`.

Rationale (not shown to the user): the question is diagnostic ("why"), so
the metric page alone is not enough, the debug playbook is required. The
NRR formula decomposes into retained + expansion − contraction − churn
over a frozen t0 denominator, so loading `expansion-rate.md` lets the
assistant tell the user whether the drop came from the numerator's
expansion arm or its retention arm.

### Assistant: emitting MetricFlow query

```
mf query \
  --metrics nrr,expansion_rate,grr \
  --group-by metric_time__month,cohort_arr_row__cohort_month__month \
  --where "metric_time__month >= '2026-07-01' and metric_time__month <= '2026-09-01'"
```

The query shape is lifted verbatim from the "How to query" section of
`skills/metrics/nrr.md`, extended with the two sibling metrics the debug
skill names as the first branch of the decision tree.

### Query result (abbreviated)

```
cohort_month | reporting_month | nrr  | expansion_rate | grr
2025-10-01   | 2026-07-01      | 1.08 | 0.12           | 0.96
2025-10-01   | 2026-08-01      | 1.05 | 0.11           | 0.94
2025-10-01   | 2026-09-01      | 0.97 | 0.09           | 0.88   <-- GRR fell
2026-01-01   | 2026-07-01      | 1.04 | 0.07           | 0.97
2026-01-01   | 2026-08-01      | 1.03 | 0.07           | 0.96
2026-01-01   | 2026-09-01      | 1.02 | 0.07           | 0.95
2026-04-01   | 2026-07-01      | 1.01 | 0.02           | 0.99
2026-04-01   | 2026-08-01      | 1.00 | 0.02           | 0.98
2026-04-01   | 2026-09-01      | 1.00 | 0.02           | 0.98
```

The 2025-10 cohort moves from NRR 1.08 in July to 0.97 in September.
Expansion rate on that cohort drifts from 0.12 to 0.09, a 3-point drop , 
but GRR drops 8 points (0.96 → 0.88). The debug skill's first rule applies:
if ΔGRR is larger than Δexpansion, the move is a retention story, not an
expansion story.

### Assistant: one-sentence answer

> Q3 NRR fell because the 2025-10 cohort's GRR dropped from 0.94 to 0.88
> in September, one large customer in that cohort contracted (see
> `fct_mrr_movement` where `account_sk = <sk>` and
> `movement_type = 'contraction'` in 2026-09); expansion stayed roughly
> flat at ~0.09, so the aggregate NRR tracked the GRR dip rather than
> being offset by expansion. Newer cohorts are healthy, this is a single
> cohort effect, not a portfolio-wide trend.

### What the pattern bought us

- **Cohort-static attribution, honestly.** The assistant did not conflate
  "new logos acquired in Q3" with "retention of the 2025-10 cohort." The
  gotcha in `nrr.md` ("Denominator freezes at t0") routed the model past
  the most common NRR mistake.
- **Honest routing to the right skill files.** The question-word "why"
  triggered the debug skill; the debug skill named the sibling metrics;
  the sibling metrics' own frontmatter listed their dimensions. No file
  was speculative, each one earned its place in the context window.
- **Concrete MetricFlow syntax, not SQL.** The assistant emitted a
  governed `mf query`, not hand-rolled SQL. If next quarter the cohort
  grain changes from month to week, the skill file changes once and
  every assistant answer updates with it, the semantic layer is the
  single source of truth.
- **Deterministic answer tied to a specific movement row.** The final
  sentence points at a specific `fct_mrr_movement` row the user can
  open in a notebook. The assistant is a router to the warehouse, not a
  summarizer of its own hallucinations.

The whole trace runs under 15 seconds end-to-end. The user did not
learn SQL, did not learn MetricFlow, did not need to know that
`cohort_arr` is a semantic model. They asked a GTM question and got a
GTM answer with a citation.
