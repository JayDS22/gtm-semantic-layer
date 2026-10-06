{{ config(severity='warn') }}

-- Fires when int_account_hierarchy_reconciliation surfaces any violation
-- (orphan Stripe customer, orphan product account, or an SFDC account with
-- multiple Stripe customers).
--
-- Adversarial-pass mod (design doc §4): severity=warn on Day 2 because the
-- seed data deliberately includes 3 orphan stripe customers to demonstrate
-- the detector fires. Flip to error before shipping to a prod warehouse.

select *
from {{ ref('int_account_hierarchy_reconciliation') }}
