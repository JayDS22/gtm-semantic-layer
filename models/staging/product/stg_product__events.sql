select
    event_id,
    user_id,
    event_type,
    account_id,
    ts                 as event_at,
    property_milestone,
    property_feature,
    property_revenue
from {{ source('product', 'events') }}
