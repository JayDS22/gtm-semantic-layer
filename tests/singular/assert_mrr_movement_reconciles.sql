{{ config(severity='warn') }}

-- For each (account_sk, month_date) in fct_mrr_movement, the row's
-- arr_delta_cents must equal (curr_arr_cents - prev_arr_cents) within $1.
-- $1 = 100 cents tolerance absorbs any cents-rounding drift. A violation
-- means the movement classifier and the arithmetic disagree, which breaks
-- the identity sum(delta) = ending_arr - starting_arr.

select
    account_sk,
    month_date,
    movement_type,
    prev_arr_cents,
    curr_arr_cents,
    arr_delta_cents,
    (curr_arr_cents - prev_arr_cents)                          as expected_delta_cents,
    arr_delta_cents - (curr_arr_cents - prev_arr_cents)        as drift_cents
from {{ ref('fct_mrr_movement') }}
where abs(arr_delta_cents - (curr_arr_cents - prev_arr_cents)) > 100
