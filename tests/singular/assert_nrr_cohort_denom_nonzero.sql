{{ config(severity='warn') }}

-- fct_cohort_arr_monthly.cohort_t0_arr_cents is the denominator for NRR, GRR,
-- and expansion_rate. A zero-denominator cohort row would NaN/inf every
-- downstream ratio and silently poison dashboards. Emit any such rows.

select
    cohort_month,
    reporting_month,
    cohort_t0_arr_cents,
    cohort_now_arr_cents,
    cohort_logo_t0
from {{ ref('fct_cohort_arr_monthly') }}
where cohort_t0_arr_cents = 0
