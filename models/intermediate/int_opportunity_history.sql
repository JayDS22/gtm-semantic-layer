-- ponytail: Day 2 captures current state only. True SCD2 history requires a
-- dbt snapshot on stg_sfdc__opportunities + join; defer until stage-transition
-- timing becomes an input to avg_sales_cycle quality (currently derived from
-- close_date − created_date in fct_opportunity).

select
    opportunity_id,
    account_id,
    owner_user_id,
    stage,
    forecast_category,
    amount_cents,
    created_at,
    close_date,
    last_modified_at,
    current_timestamp as snapshot_at
from {{ ref('stg_sfdc__opportunities') }}
