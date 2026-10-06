{% test assert_grain(model, columns) %}
  {#- Asserts the tuple `columns` is unique AND non-null on `model`.
      More readable in schema.yml than two separate tests (unique_combination_of_columns + not_null on each). -#}
  with g as (
    select {{ columns | join(', ') }}
    from {{ model }}
    where {% for c in columns -%}
      {{ c }} is not null{% if not loop.last %} and {% endif %}
    {%- endfor %}
    group by {{ columns | join(', ') }}
    having count(*) > 1
  )
  select * from g
{% endtest %}
