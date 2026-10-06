# The `skills/` Pattern

## Attribution

I built this pattern after reading Anthropic's June 2026 post, "How Anthropic
enables self-service data analytics with Claude." The post describes a
`skills/` folder of versioned markdown files that an internal assistant loads
before answering a GTM question, one file per metric, plus debug playbooks
and FAQs, alongside a PII taxonomy that keeps the assistant from leaking
identifiers. I lifted the folder shape and the PII taxonomy from that post as
a sincere reconstruction. The specific metrics, warehouse schema, semantic
models, and CI checks in this repo are my own work.

## Three categories

Every file lives under `skills/<category>/<id>.md`.

- **`skills/metrics/`**, one file per public metric. Formula, dimensions,
  how-to-query, gotchas, owner, update cadence. The assistant loads one of
  these to answer "what is X?" or "query X."
- **`skills/debug/`**, playbooks for "why did X move?" questions. These
  encode the two or three investigative moves a seasoned analyst would run
  (e.g. `skills/debug/nrr-cohort-attribution.md` on an NRR drop,
  `skills/debug/pipeline-stage-regression.md` on coverage drift).
- **`skills/faq/`**, short pages that disambiguate commonly-conflated
  concepts: `what-is-mrr-vs-arr.md`, `how-do-we-define-churn.md`,
  `pipeline-coverage-strict-vs-qtd.md`, `what-counts-as-expansion.md`.

## Frontmatter schema

Every file starts with YAML frontmatter whose schema lives at
`skills/_frontmatter_schema.yml`. Required fields:

- `metric_id`, kebab-case; required on `skills/metrics/*.md`, omit for
  debug/faq
- `category`, `metric | debug | faq`
- `owner`, team email
- `confidence_tier`, `stable | evolving | draft`
- `pii_sensitive`, boolean
- `last_reviewed_at`, `YYYY-MM-DD`
- `update_cadence`, `weekly | monthly | quarterly | on_change`

Optional: `dimensions` (safe grouping dims for the assistant) and
`related_skills` (kebab-case ids pointing at other files).

## CI: skill ⇄ metric crosswalk

`scripts/skill_metric_crosswalk.py` reads
`target/semantic_manifest.json` after `dbt parse` and performs an
**orphan-only** check: every `skills/metrics/<id>.md` must declare a
`metric_id` that resolves to a real MetricFlow metric. The script does NOT
require every MetricFlow metric to have a skill file, the inline comment
inside the script explains why: supporting metrics (`new_arr`,
`cohort_now_arr`, `won_opps`, `cycle_days_total`, etc.) are inputs to
derived/ratio parents and are not "public." Only the 22 public metrics
(per the design doc §1.5 and the glossary in this folder) warrant skill
files. The check prevents a skill from pointing at a dead or renamed
metric; it does not force new metrics to ship with a page they don't need.

## Example trip

User in Slack: `@claude what's our Q3 NRR by cohort?`

1. Assistant loads `skills/metrics/nrr.md` (formula, dimensions, gotcha
   that denominator freezes at t0).
2. It also loads `skills/debug/nrr-cohort-attribution.md` so it knows how
   to explain the result if the user follows up.
3. It emits the MetricFlow query copy-pasted from `nrr.md`'s "How to
   query" section:
   `mf query --metrics nrr --group-by metric_time__month,cohort_arr__cohort_month__month --where "metric_time__month between '2026-07-01' and '2026-09-30'"`
4. It answers in one sentence, cites the cohort month, and offers the
   debug skill as a follow-up.
