select
    {{ dbt_utils.generate_surrogate_key(['team', 'quarter_start']) }} as quota_sk,
    team,
    cast(quarter_start as date) as quarter_start,
    cast(quota_cents as bigint) as quota_arr_cents
from {{ ref('quotas') }}
