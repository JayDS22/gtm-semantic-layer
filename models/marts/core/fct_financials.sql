-- Day 5 polish: segment-weighted CAC denominator now joins REAL new_arr by
-- segment (int_new_arr_by_segment, derived from fct_mrr_movement x
-- dim_account.segment) with seeded gross_margin_pct + segment_mix_pct from
-- segment_margins. Lifts cac_payback_months from evolving to stable.

with f as (
    select * from {{ ref('financials') }}
),

sm_inputs as (
    select
        s.quarter_start,
        s.segment,
        s.gross_margin_pct,
        s.segment_mix_pct,
        coalesce(n.new_arr_cents, 0) as new_arr_cents
    from {{ ref('segment_margins') }} s
    left join {{ ref('int_new_arr_by_segment') }} n
      on n.quarter_start = s.quarter_start
     and n.segment       = s.segment
),

sm as (
    select
        quarter_start,
        sum(new_arr_cents * gross_margin_pct * segment_mix_pct) as segment_weighted_cac_denom_cents
    from sm_inputs
    group by quarter_start
)

select
    {{ dbt_utils.generate_surrogate_key(['f.quarter_start']) }}        as financials_sk,
    cast(f.quarter_start as date)                                      as quarter_start,
    cast(f.sm_spend_cents as bigint)                                   as sm_spend_cents,
    cast(f.revenue_cents as bigint)                                    as revenue_cents,
    cast(f.cogs_cents as bigint)                                       as cogs_cents,
    cast(f.net_burn_cents as bigint)                                   as net_burn_cents,
    cast(f.gross_margin_pct as double)                                 as gross_margin_pct,
    cast(f.operating_margin_pct as double)                             as operating_margin_pct,
    coalesce(cast(sm.segment_weighted_cac_denom_cents as double), 0.0) as segment_weighted_cac_denom_cents
from f
left join sm on sm.quarter_start = f.quarter_start
