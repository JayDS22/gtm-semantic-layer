-- Cohort-static ARR aggregation. One row per (cohort_month × reporting_month).
--
-- Downstream metrics (declared in models/semantic/cohort.yml):
--   NRR            = cohort_now_arr      / cohort_t0_arr
--   GRR            = cohort_retained_arr / cohort_t0_arr      (capped at t0 per account)
--   expansion_rate = (cohort_now_arr - cohort_retained_arr) / cohort_t0_arr
--   logo_retention = cohort_logo_now     / cohort_logo_t0
--
-- Attribution semantics (adversarial-pass gotcha, see skills/metrics/nrr.md):
--   - cohort is STATIC, accounts that join a new logo mid-period do NOT get
--     attributed to any prior cohort
--   - cohort_t0_arr is the sum of each account's ARR as of its cohort_month,
--     frozen for that cohort forever
--   - partial-month cohorts (e.g., July-15 account) land in the account's
--     first-non-zero-ARR month = July (first-paid-month rule)

with ac as (
    select account_sk, cohort_month from {{ ref('int_account_cohort') }}
),

account_month as (
    select account_sk, month_date, arr_cents from {{ ref('int_account_arr_monthly') }}
),

-- t0 ARR per account (frozen at cohort_month)
t0_arr as (
    select
        ac.account_sk,
        ac.cohort_month,
        ama.arr_cents as t0_arr_cents
    from ac
    join account_month ama
      on ama.account_sk = ac.account_sk
     and ama.month_date = ac.cohort_month
),

month_spine as (
    select distinct cast(first_of_month as date) as reporting_month
    from {{ ref('dim_date') }}
),

-- Only report (cohort, reporting_month) pairs where reporting_month >= cohort_month and <= now
cohort_month_pairs as (
    select distinct
        t0.cohort_month,
        ms.reporting_month
    from t0_arr t0
    cross join month_spine ms
    where ms.reporting_month >= t0.cohort_month
      and ms.reporting_month <= cast(date_trunc('month', current_date) as date)
),

-- For each (cohort × reporting_month × account in cohort), get current ARR (0 if churned)
cohort_account_report as (
    select
        cmp.cohort_month,
        cmp.reporting_month,
        t0.account_sk,
        t0.t0_arr_cents,
        coalesce(ama.arr_cents, 0) as curr_arr_cents
    from cohort_month_pairs cmp
    join t0_arr t0 on t0.cohort_month = cmp.cohort_month
    left join account_month ama
      on ama.account_sk = t0.account_sk
     and ama.month_date = cmp.reporting_month
)

select
    cohort_month,
    reporting_month,
    sum(curr_arr_cents)                                              as cohort_now_arr_cents,
    sum(least(curr_arr_cents, t0_arr_cents))                         as cohort_retained_arr_cents,
    sum(t0_arr_cents)                                                as cohort_t0_arr_cents,
    count(distinct account_sk)                                       as cohort_logo_t0,
    count(distinct case when curr_arr_cents > 0 then account_sk end) as cohort_logo_now
from cohort_account_report
group by cohort_month, reporting_month
