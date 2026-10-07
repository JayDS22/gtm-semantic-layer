-- Day 5+ polish: real new_arr by segment per quarter, derived from
-- fct_mrr_movement x dim_account.segment. Replaces the previously-seeded
-- `new_arr_cents` column of segment_margins (which only carries GM + mix now).
-- Enables cac_payback_months to lift from evolving to stable.

with new_arr as (
    select
        account_sk,
        month_date,
        curr_arr_cents - prev_arr_cents as new_arr_cents
    from {{ ref('fct_mrr_movement') }}
    where movement_type = 'new'
      and curr_arr_cents > prev_arr_cents
)

select
    cast(date_trunc('quarter', na.month_date) as date) as quarter_start,
    da.segment,
    sum(na.new_arr_cents) as new_arr_cents
from new_arr na
join {{ ref('dim_account') }} da on da.account_sk = na.account_sk
group by quarter_start, da.segment
