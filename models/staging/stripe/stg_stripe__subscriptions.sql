select
    subscription_id || '|' || cast(valid_from as varchar)  as subscription_event_id,
    subscription_id,
    customer_id,
    plan_id,
    status,
    quantity,
    cast(unit_amount * 100 as bigint)                       as unit_amount_cents,
    valid_from,
    valid_to
from {{ source('stripe', 'subscriptions') }}
