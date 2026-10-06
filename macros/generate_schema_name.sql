{% macro generate_schema_name(custom_schema_name, node) -%}
    {#-
      dbt-labs recommended override: when a model/seed sets `+schema: X`,
      write to literal schema `X` instead of the default `{target.schema}_X`.
      This lets source YAML (`schema: raw`) and seed config (`+schema: raw`)
      resolve to the same physical schema in DuckDB.
      Reference: https://docs.getdbt.com/docs/build/custom-schemas
    -#}
    {%- set default_schema = target.schema -%}
    {%- if custom_schema_name is none -%}
        {{ default_schema }}
    {%- else -%}
        {{ custom_schema_name | trim }}
    {%- endif -%}
{%- endmacro %}
