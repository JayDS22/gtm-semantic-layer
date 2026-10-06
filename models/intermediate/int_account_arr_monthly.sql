-- Dense month-end ARR per account. Zero for months after churn or before first "new".
-- Downstream:
--   fct_mrr_movement       (classifies movements via lag)
--   int_account_cohort     (first non-zero month per account = cohort_month)
--   fct_cohort_arr_monthly (per-cohort aggregation)
--
-- Extracted from fct_mrr_movement on Day 3 so the densification is reused once,
-- not duplicated across two downstream marts.

with month_end_customer_mrr as (
    select
        customer_id,
        cast(date_trunc('month', calendar_date) as date) as month_date,
        sum(mrr_cents) as mrr_cents
    from {{ ref('int_subscription_mrr_daily') }}
    where calendar_date = cast(date_trunc('month', calendar_date) + interval 1 month - interval 1 day as date)
    group by customer_id, month_date
),

account_month_arr_raw as (
    select
        c.account_sk,
        m.month_date,
        sum(m.mrr_cents) * 12 as arr_cents
    from month_end_customer_mrr m
    join {{ ref('dim_customer') }} c on c.customer_id = m.customer_id
    where c.account_sk is not null
    group by c.account_sk, m.month_date
),

account_month_range as (
    select
        account_sk,
        min(month_date) as first_month,
        greatest(max(month_date), cast(date_trunc('month', current_date) as date)) as last_month
    from account_month_arr_raw
    group by account_sk
),

month_spine as (
    select distinct cast(first_of_month as date) as month_date from {{ ref('dim_date') }}
)

select
    amr.account_sk,
    ms.month_date,
    coalesce(aama.arr_cents, 0) as arr_cents
from account_month_range amr
cross join month_spine ms
left join account_month_arr_raw aama
  on aama.account_sk = amr.account_sk
 and aama.month_date = ms.month_date
where ms.month_date between amr.first_month and amr.last_month
