# PII Policy

This project uses the 4-level PII taxonomy from Anthropic's June 2026 post "How
Anthropic enables self-service data analytics with Claude." Every column that
could identify a person or an account carries one of these labels in dbt
column `meta`, and a CI check enforces that labels propagate downstream.

## The four levels

### 1. `direct_identifier`
A value that identifies a specific person on its own.

Examples in this warehouse: `stg_sfdc__users.email`,
`stg_sfdc__users.first_name`, `stg_sfdc__users.last_name`,
`stg_stripe__customers.billing_email`.

Rule: `direct_identifier` columns MUST be dropped at the staging→mart
boundary. The semantic layer never sees them. See
`models/marts/core/dim_user.sql`, the header comment states this explicitly
and the SELECT list drops email/first_name/last_name while keeping
`user_sk`, `title`, `team`, `is_internal`.

### 2. `indirect_identifier`
A value that can identify a person only when combined with others.

Examples: `stg_sfdc__users.title` (unique within a small team),
`stg_sfdc__users.team`, `stg_funnel_event.ip_address`.

Rule: allowed in marts and the semantic layer, but not safe to publish
in low-k aggregations without a k-anonymity floor (not yet enforced, Day 4+).

### 3. `customer_identifier`
A value that identifies a paying account, not a person.

Examples: `stg_sfdc__accounts.account_id`, `stg_stripe__customers.customer_id`,
all `*_sk` surrogate keys downstream.

Rule: allowed everywhere in the pipeline. The semantic layer slices by
`account_sk` freely.

### 4. `sensitive_attribute`
A value that is not an identifier but is sensitive to disclose.

Examples: `stg_stripe__subscriptions.mrr_cents` at account grain,
`fct_financials.net_burn_cents`, `fct_opportunity.arr_cents`.

Rule: allowed in the semantic layer. Downstream permissions (not yet
implemented) will restrict who can group by `account_sk` on these measures.

## Enforcement

The `tag_pii` macro at `macros/tag_pii.sql` is the central place to document
levels (columns use plain `meta: { pii: <level> }` in `schema.yml` since
Jinja is not evaluated in YAML).

`scripts/pii_check.py` walks `target/manifest.json` and performs three
checks:

1. **Direct-identifier drop at mart boundary.** Any column tagged
   `direct_identifier` in a staging model must NOT appear by the same name
   in any `fct_*`/`dim_*` mart. `dim_user` is the canonical example.
2. **PII propagation.** If an intermediate or mart column is a straight
   rename of a staging column tagged `indirect_identifier` or above, the
   downstream column must carry the same (or stricter) tag.
3. **No untagged PII-shaped columns.** Columns named `email`,
   `first_name`, `last_name`, `phone`, `ip_address`, `ssn`, `*_email`
   anywhere in the DAG must carry an explicit PII tag or the check fails
   loudly (fail-closed on anything that looks like PII).

CI runs this after `dbt parse` so the manifest is current.
