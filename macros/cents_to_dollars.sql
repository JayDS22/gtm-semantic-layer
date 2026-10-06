{% macro cents_to_dollars(col) %}
  {#- Convert cents to dollars at the BI boundary only. Staging and marts
      stay in cents (immutable money rule). The semantic layer uses
      `meta.divide_by: 100` for the same purpose; this macro is for ad-hoc
      BI SQL (Hex panels etc.). -#}
  ({{ col }} / 100.0)
{% endmacro %}
