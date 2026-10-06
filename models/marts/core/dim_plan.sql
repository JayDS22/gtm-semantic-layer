select
    {{ dbt_utils.generate_surrogate_key(['plan_id']) }} as plan_sk,
    plan_id,
    plan_name,
    tier,
    cast(base_monthly_cents as bigint) as base_monthly_cents,
    cast(cogs_pct as double)           as cogs_pct
from {{ ref('pricing_plans') }}
