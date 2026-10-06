with opp as (
    select * from {{ ref('int_opportunity_history') }}
),

acc as (
    select account_id, account_sk from {{ ref('dim_account') }}
),

usr as (
    select user_id, user_sk, team from {{ ref('dim_user') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['opp.opportunity_id']) }} as opportunity_sk,
    opp.opportunity_id,
    acc.account_sk,
    usr.user_sk,
    usr.team                                         as owner_team,
    opp.stage,
    opp.forecast_category,
    opp.amount_cents                                 as arr_cents,
    (opp.stage = 'Closed Won')                       as is_won,
    (opp.stage = 'Closed Lost')                      as is_lost,
    (opp.stage not in ('Closed Won', 'Closed Lost')) as is_open,
    cast(opp.created_at as date)                     as created_date,
    opp.close_date                                   as close_date,
    case when opp.stage in ('Closed Won', 'Closed Lost')
         then cast(opp.close_date - cast(opp.created_at as date) as integer)
         else null end                               as cycle_days
from opp
left join acc on acc.account_id = opp.account_id
left join usr on usr.user_id   = opp.owner_user_id
