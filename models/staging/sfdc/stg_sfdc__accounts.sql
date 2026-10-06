select
    id          as account_id,
    name        as account_name,
    segment,
    region,
    industry,
    created_at
from {{ source('sfdc', 'accounts') }}
