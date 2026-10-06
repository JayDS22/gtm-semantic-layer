with d as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2025-01-01' as date)",
        end_date="cast('2028-01-01' as date)"
    ) }}
)

select
    cast(date_day as date)                           as calendar_date,
    extract('year'    from date_day)::int            as calendar_year,
    extract('quarter' from date_day)::int            as calendar_quarter,
    extract('month'   from date_day)::int            as calendar_month,
    extract('day'     from date_day)::int            as calendar_day,
    date_trunc('month',   date_day)::date            as first_of_month,
    date_trunc('quarter', date_day)::date            as first_of_quarter,
    date_trunc('year',    date_day)::date            as first_of_year
from d
