{%  set yaml_metadata  %}
custom_rsrc: merge Satellite 1 and 2 for test
parent_model: hub
key_column: hk1
source_models:
  sat1:
      column_prefix: ''
      hash_diff_input: [name, cdc_operation, src3_bk, city]
  sat2:
      column_prefix: ''
      hash_diff_input: [phone]
add_hash_diff_payload: true
incremental_delta_check: false
{%  endset  %}

{{ delta_merge_sat(yaml_metadata) }}
