{{ config(
    materialized='incremental',
    unique_key='subscription_day_key',
    incremental_strategy='merge',
    on_schema_change='sync_all_columns'
) }}

-- ponytail: incremental+merge because daily-densifying N subs × ~90-700 days
-- doubles table size each year. Full rebuild is fine today (<30s on DuckDB) but
-- becomes the dominant build-time cost by ~50 subs × 2y data. Adversarial-pass
-- mod flagged this as the highest-signal production-awareness change.
--
-- ponytail: the incremental filter below is naive (calendar_date > last_max).
-- It does NOT handle late-arriving status changes to existing subs (e.g., a
-- sub flipped from active to canceled retroactively). Production fix: filter
-- by stg_stripe__subscriptions.last_modified_at > last_run_at and re-densify
-- those subs. Day 4-5 task when status-change CDC becomes real.

with periods as (
    select
        subscription_id,
        customer_id,
        plan_id,
        quantity * unit_amount_cents                     as mrr_cents,
        cast(valid_from as date)                         as start_date,
        cast(coalesce(valid_to, current_date) as date)   as end_date
    from {{ ref('stg_stripe__subscriptions') }}
    where status in ('active', 'past_due')
),

exploded as (
    select
        p.subscription_id,
        p.customer_id,
        p.plan_id,
        cast(d as date) as calendar_date,
        p.mrr_cents
    from periods p,
         unnest(generate_series(p.start_date, p.end_date, interval 1 day)) t(d)
)

select
    subscription_id || '|' || cast(calendar_date as varchar) as subscription_day_key,
    subscription_id,
    customer_id,
    plan_id,
    calendar_date,
    mrr_cents
from exploded
{% if is_incremental() %}
where calendar_date > (select coalesce(max(calendar_date), cast('1900-01-01' as date)) from {{ this }})
{% endif %}
