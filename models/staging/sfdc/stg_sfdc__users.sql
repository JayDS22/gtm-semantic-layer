select
    id          as user_id,
    email       as user_email,
    first_name,
    last_name,
    title,
    team,
    created_at
from {{ source('sfdc', 'users') }}
