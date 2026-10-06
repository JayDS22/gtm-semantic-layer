select
    id          as customer_id,
    email       as customer_email,
    account_id,
    created_at
from {{ source('stripe', 'customers') }}
