{% macro tag_pii(level) %}
  {#-
    Returns a meta dict `{pii: <level>}` for inline use in column config.
    The CI check `scripts/pii_check.py` walks target/manifest.json for this
    key and asserts PII propagation per docs/pii-policy.md.

    Levels: direct_identifier, indirect_identifier, customer_identifier, sensitive_attribute.

    Usage in schema.yml (jinja is NOT evaluated in YAML, this macro is
    documentation + a central place to add validation when needed;
    columns use plain `meta: { pii: ... }` for now):
      columns:
        - name: email
          meta: { pii: direct_identifier }
  -#}
  {{ return({'pii': level}) }}
{% endmacro %}
