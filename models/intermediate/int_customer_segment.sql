-- ponytail: Day 2 trusts the sfdc_accounts.segment column directly.
-- Day 3+ can replace with ARR-tier derivation from fct_mrr_movement.
-- Keeping the model surface so downstream dims don't need to be rewritten
-- when the derivation logic changes.

select
    account_id,
    segment,
    cast('seed' as varchar) as segment_source
from {{ ref('stg_sfdc__accounts') }}
