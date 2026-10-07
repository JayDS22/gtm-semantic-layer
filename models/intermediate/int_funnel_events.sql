-- Classify product events to funnel stages, attach account_sk.
-- The product user_id namespace is separate from sfdc_users.id, so dim_user
-- is intentionally not joined, funnel analytics happen at account grain.

with evt as (
    select * from {{ ref('stg_product__events') }}
),

a as (
    select account_id, account_sk from {{ ref('dim_account') }}
)

select
    evt.event_id,
    a.account_sk,
    evt.user_id as external_user_id,
    case
        when evt.event_type = 'visit'                        then 'visit'
        when evt.event_type = 'signup'                       then 'signup'
        when evt.event_type = 'mql_qualified'                then 'mql'
        when evt.event_type = 'sql_qualified'                then 'sql'
        when evt.event_type = 'activation_milestone_reached' then 'activation'
        when evt.event_type = 'expansion_event'              then 'expansion'
        else null
    end                                                   as funnel_stage,
    evt.event_at,
    evt.property_milestone,
    evt.property_feature,
    evt.property_revenue
from evt
left join a on a.account_id = evt.account_id
