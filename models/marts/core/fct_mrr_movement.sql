-- One row per account × month × movement_type.
-- Day 3 refactor: densification extracted to int_account_arr_monthly, which is
-- also consumed by fct_cohort_arr_monthly. This file now only classifies.
--
-- Movement types: new, expansion, contraction, churn.
-- Reactivation (churned-then-returned) collapses into 'new' until Day 4+ when
-- we add explicit prior-nonzero-history detection.

with with_prev as (
    select
        account_sk,
        month_date,
        arr_cents                                                               as curr_arr_cents,
        lag(arr_cents, 1, 0) over (partition by account_sk order by month_date) as prev_arr_cents
    from {{ ref('int_account_arr_monthly') }}
),

movements as (
    select
        account_sk,
        month_date,
        prev_arr_cents,
        curr_arr_cents,
        curr_arr_cents - prev_arr_cents as arr_delta_cents,
        case
            when prev_arr_cents = 0 and curr_arr_cents > 0                  then 'new'
            when prev_arr_cents > 0 and curr_arr_cents = 0                  then 'churn'
            when curr_arr_cents > prev_arr_cents and prev_arr_cents > 0     then 'expansion'
            when curr_arr_cents < prev_arr_cents and curr_arr_cents > 0     then 'contraction'
            else null
        end as movement_type
    from with_prev
)

select
    account_sk,
    month_date,
    movement_type,
    prev_arr_cents,
    curr_arr_cents,
    arr_delta_cents
from movements
where movement_type is not null
