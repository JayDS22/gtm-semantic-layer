select
    id                                      as opportunity_id,
    account_id,
    owner_user_id,
    name                                    as opportunity_name,
    stage,
    forecast_category,
    cast(amount * 100 as bigint)            as amount_cents,
    close_date,
    created_at,
    last_modified_at
from {{ source('sfdc', 'opportunities') }}
