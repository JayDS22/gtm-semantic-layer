{{ config(severity='warn') }}

-- Adversarial-pass reconciliation (design doc §4).
-- For each quarter in fct_financials:
--   ttm_revenue    = sum(revenue_cents) over trailing 4 quarters (incl. current)
--   run_rate_arr   = sum(curr_arr_cents) across all accounts at the quarter's
--                    end-of-quarter month in fct_mrr_movement
-- Fail when |ttm_revenue - run_rate_arr| / ttm_revenue > 15%.
--
-- 15% is a demo-wide band because this repo has 10 months of mock data and
-- partial-TTM windows will dominate early rows. Real prod band: 2–3%.
-- ponytail: 15% tolerance, tighten to 2-3% once >=4 quarters of real data.

with q as (
    select
        quarter_start,
        revenue_cents,
        sum(revenue_cents) over (
            order by quarter_start
            rows between 3 preceding and current row
        ) as ttm_revenue_cents
    from {{ ref('fct_financials') }}
),

eoq_month as (
    -- end-of-quarter month = quarter_start + 2 months (first day of month 3)
    select
        quarter_start,
        ttm_revenue_cents,
        cast(date_trunc('month', quarter_start + interval 2 month) as date) as eoq_month
    from q
),

arr_at_eoq as (
    select
        month_date,
        sum(curr_arr_cents) as run_rate_arr_cents
    from {{ ref('fct_mrr_movement') }}
    group by month_date
)

select
    e.quarter_start,
    e.eoq_month,
    e.ttm_revenue_cents,
    a.run_rate_arr_cents,
    (e.ttm_revenue_cents - a.run_rate_arr_cents)                                   as drift_cents,
    abs(e.ttm_revenue_cents - a.run_rate_arr_cents) * 1.0
        / nullif(e.ttm_revenue_cents, 0)                                           as drift_pct
from eoq_month e
join arr_at_eoq a on a.month_date = e.eoq_month
where e.ttm_revenue_cents > 0
  and abs(e.ttm_revenue_cents - a.run_rate_arr_cents) * 1.0
        / nullif(e.ttm_revenue_cents, 0) > 0.15
