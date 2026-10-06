---
category: faq
owner: gtm-analytics@example.com
confidence_tier: stable
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: on_change
related_skills: [pipeline-coverage, pipeline-coverage-qtd, win-rate]
---

# Pipeline coverage — strict vs QTD

Two coverage definitions circulate in SaaS, and your sales leadership probably argues about which is "right". We ship both deliberately (adversarial-pass §4).

## Strict: `pipeline_coverage`

Numerator = `open_pipeline_arr` (open opps with forecast_category ∈ pipeline/best_case/commit).
Denominator = `quota_arr`.

**Trends DOWN as the quarter progresses** — as deals close, open pipeline shrinks. This is the forward-looking view: "do we have enough runway to still hit?"

Industry rule-of-thumb: ≥3x at quarter start is healthy; ≥1x by mid-quarter is usually required to hit.

## Inclusive: `pipeline_coverage_qtd`

Numerator = `qtd_pipeline_arr` (open + closed_won in-period).
Denominator = `quota_arr`.

**Trends UP as the quarter progresses** — closed deals accumulate. This is the attainment view: "where are we vs quota, including progress so far?"

Industry rule-of-thumb: ≥1x by end of quarter = quota hit.

## Why we expose both

- CROs often want the strict view mid-quarter to pressure-test pipeline health.
- CFOs often want QTD to understand attainment risk.
- Executive reports frequently mislabel one as the other, confusing the audience.

## Pick a lane

Our default = **strict**. If your org uses the QTD convention as its primary KPI, flip the public one in docs/metric-glossary.md and keep both in the layer.
