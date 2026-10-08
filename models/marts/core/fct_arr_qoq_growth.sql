-- Day 6: quarter-end total ARR + QoQ-annualized growth rate.
-- Enables the growth-rate term of rule_of_40 (Bessemer's "growth + margin >= 40").
-- QoQ-annualized = (1 + qoq)^4 - 1. Bessemer's canonical convention is YoY,
-- but QoQ-annualized is accepted for high-growth stage companies and is what the
-- limited demo seed can resolve (only 4 complete quarters, YoY would be null).
-- See skills/metrics/arr-qoq-growth-pct.md for the convention tradeoff.

with monthly as (
    select
        cast(date_trunc('quarter', month_date) as date) as quarter_start,
        month_date,
        account_sk,
        arr_cents
    from {{ ref('int_account_arr_monthly') }}
),

quarter_end_month_per_quarter as (
    select quarter_start, max(month_date) as quarter_end_month
    from monthly
    group by quarter_start
),

quarter_end_arr as (
    select
        m.quarter_start,
        qe.quarter_end_month,
        sum(m.arr_cents) as arr_cents
    from monthly m
    join quarter_end_month_per_quarter qe
      on qe.quarter_start = m.quarter_start
     and qe.quarter_end_month = m.month_date
    where qe.quarter_end_month >= date_add(cast(m.quarter_start as date), interval '2 months')
    group by m.quarter_start, qe.quarter_end_month
),

qoq as (
    select
        quarter_start,
        arr_cents,
        lag(arr_cents, 1) over (order by quarter_start) as arr_cents_prev_q
    from quarter_end_arr
)

select
    quarter_start,
    arr_cents,
    arr_cents_prev_q,
    case
        when arr_cents_prev_q is null or arr_cents_prev_q = 0 then null
        else power(1.0 + (arr_cents - arr_cents_prev_q) * 1.0 / arr_cents_prev_q, 4) - 1
    end as arr_qoq_annualized_growth_pct
from qoq
