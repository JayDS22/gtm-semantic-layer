{{ config(materialized='view') }}

-- Reconciles the three account/customer graphs:
--   SFDC accounts (source of truth for the GTM org chart)
--   Stripe customers (via account_id FK)
--   Product events (via account_id tag)
--
-- Returns one row per violation. The singular test
--   tests/singular/assert_one_customer_per_account_hierarchy.sql
-- asserts this view is empty.
--
-- Adversarial-pass mod (§4): the hardest problem in a real GTM semantic
-- layer is reconciling SFDC's account tree with Stripe's customer tree with
-- product's workspace id. Day 2 seeds deliberately include 3 orphan stripe
-- customers so this detector surfaces real rows (severity=warn so CI stays
-- green). Flip to severity=error before shipping to prod.

with sfdc_accounts as (
    select account_id from {{ ref('stg_sfdc__accounts') }}
),

stripe_customers as (
    select account_id, customer_id from {{ ref('stg_stripe__customers') }}
),

product_accounts as (
    select distinct account_id
    from {{ ref('stg_product__events') }}
    where account_id is not null
),

stripe_orphans as (
    select
        cast('stripe_customer_no_sfdc_account' as varchar) as reason,
        c.account_id                                       as entity_id,
        c.customer_id                                      as detail
    from stripe_customers c
    left join sfdc_accounts a using (account_id)
    where a.account_id is null
),

product_orphans as (
    select
        cast('product_account_no_sfdc_account' as varchar) as reason,
        p.account_id                                       as entity_id,
        cast(null as varchar)                              as detail
    from product_accounts p
    left join sfdc_accounts a using (account_id)
    where a.account_id is null
),

multi_customer as (
    select
        cast('sfdc_account_multi_stripe_customer' as varchar) as reason,
        c.account_id                                          as entity_id,
        cast(count(*) as varchar)                             as detail
    from stripe_customers c
    group by c.account_id
    having count(*) > 1
)

select * from stripe_orphans
union all
select * from product_orphans
union all
select * from multi_customer
