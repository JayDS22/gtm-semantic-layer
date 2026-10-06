-- PII policy: customer_email dropped at this mart boundary.
-- Orphan stripe customers (no matching SFDC account) carry a null
-- account_sk — fct_mrr_movement filters them out so their MRR does not
-- roll up to any account. int_account_hierarchy_reconciliation surfaces
-- these as warnings in CI.

with c as (
    select * from {{ ref('stg_stripe__customers') }}
),

a as (
    select account_id, account_sk from {{ ref('dim_account') }}
)

select
    {{ dbt_utils.generate_surrogate_key(['c.customer_id']) }} as customer_sk,
    c.customer_id,
    c.account_id,
    a.account_sk,
    c.created_at
from c
left join a on a.account_id = c.account_id
