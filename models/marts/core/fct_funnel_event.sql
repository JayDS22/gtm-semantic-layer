select
    event_id,
    account_sk,
    external_user_id,
    funnel_stage,
    event_at,
    cast(event_at as date)                             as event_date,
    cast(date_trunc('week', cast(event_at as date)) as date)   as event_week,
    cast(date_trunc('month', cast(event_at as date)) as date)  as event_month,
    property_milestone,
    property_feature,
    property_revenue
from {{ ref('int_funnel_events') }}
where funnel_stage is not null
