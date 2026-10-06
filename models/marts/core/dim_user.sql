-- PII policy: email/first_name/last_name are tagged `direct_identifier` in
-- staging and intentionally dropped at this mart boundary. The semantic layer
-- can slice by user_sk, title, team, is_internal — never by name/email.

select
    {{ dbt_utils.generate_surrogate_key(['user_id']) }} as user_sk,
    user_id,
    title,
    team,
    created_at,
    false as is_internal
from {{ ref('stg_sfdc__users') }}
