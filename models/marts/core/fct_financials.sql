select
    {{ dbt_utils.generate_surrogate_key(['quarter_start']) }} as financials_sk,
    cast(quarter_start as date)        as quarter_start,
    cast(sm_spend_cents as bigint)     as sm_spend_cents,
    cast(revenue_cents as bigint)      as revenue_cents,
    cast(cogs_cents as bigint)         as cogs_cents,
    cast(net_burn_cents as bigint)     as net_burn_cents,
    cast(gross_margin_pct as double)   as gross_margin_pct,
    cast(operating_margin_pct as double) as operating_margin_pct
from {{ ref('financials') }}
