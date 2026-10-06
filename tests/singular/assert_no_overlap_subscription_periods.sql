{{ config(severity='warn') }}

-- Fires when two distinct subscription_event rows for the same subscription_id
-- have overlapping [valid_from, valid_to) windows. valid_to NULL = still open.
--
-- Overlap test (half-open): a.valid_from < coalesce(b.valid_to, 'infinity')
--                       AND b.valid_from < coalesce(a.valid_to, 'infinity')
-- Pair each overlap once via subscription_event_id ordering.

with s as (
    select subscription_event_id, subscription_id, valid_from, valid_to
    from {{ ref('stg_stripe__subscriptions') }}
)

select
    a.subscription_id,
    a.subscription_event_id as event_a,
    b.subscription_event_id as event_b,
    a.valid_from            as a_from,
    a.valid_to              as a_to,
    b.valid_from            as b_from,
    b.valid_to              as b_to
from s a
join s b
  on  a.subscription_id      = b.subscription_id
  and a.subscription_event_id < b.subscription_event_id
  and a.valid_from < coalesce(b.valid_to, date '9999-12-31')
  and b.valid_from < coalesce(a.valid_to, date '9999-12-31')
