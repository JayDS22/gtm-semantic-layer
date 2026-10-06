---
metric_id: gross_margin
category: metric
owner: gtm-analytics@example.com
confidence_tier: stable
dimensions: [quarter]
pii_sensitive: false
last_reviewed_at: 2026-10-06
update_cadence: quarterly
related_skills: [cac-payback-months, rule-of-40]
---

# Gross Margin, Revenue Minus COGS

## One-liner
Share of revenue left after cost of goods sold, the "software is high-margin" story told in one number. 75-85% is the healthy SaaS band; dipping below 70% usually indicates heavy services load, infra inefficiency, or payment-processor drag.

## Formula
`(revenue - cogs) / revenue`
Expressed as a decimal (0.78 = 78%).

## Dimensions you can slice by
- `metric_time__quarter`, matches the financials seed grain

## How to query
`mf query --metrics gross_margin --group-by metric_time__quarter`

## Gotchas
1. **COGS definition is opinionated.** Our financials seed includes hosting + support + payment processing but excludes R&D (SG&A convention). Different orgs include different lines, some capitalize a portion of engineering into COGS, some don't. Always ask what's in the denominator before comparing cross-company.
2. **Blended across all plan tiers.** SMB plans typically have lower per-dollar COGS due to self-serve support; enterprise carries dedicated CSMs and higher infra. Averaging obscures this, a shift in mix moves blended GM without any underlying efficiency change.

## When NOT to use gross_margin
- Contribution margin (gross margin minus S&M) → not shipped
- Segment-level economics → use segment-weighted gross margin (deferred to Day 4+)

## Owner, update cadence
Owned by GTM Analytics. Reviewed quarterly.
