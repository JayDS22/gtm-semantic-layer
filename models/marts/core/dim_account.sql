with a as (
    select * from {{ ref('stg_sfdc__accounts') }}
),

seg as (
    select account_id, segment, segment_source from {{ ref('int_customer_segment') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['a.account_id']) }} as account_sk,
    a.account_id,
    a.account_name,
    coalesce(seg.segment, a.segment) as segment,
    seg.segment_source,
    a.region,
    a.industry,
    a.created_at,
    true as is_current
from a
left join seg on seg.account_id = a.account_id
