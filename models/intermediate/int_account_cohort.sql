-- Cohort_month per account = first month where the account had non-zero ARR.
-- Used by fct_cohort_arr_monthly for cohort-static NRR/GRR/expansion/logo-retention.
-- Deliberately NOT merged into dim_account (would create a dim→int→mart cycle via
-- fct_mrr_movement → dim_customer → dim_account); keep cohort in the int layer.

select
    account_sk,
    min(month_date) as cohort_month
from {{ ref('int_account_arr_monthly') }}
where arr_cents > 0
group by account_sk
