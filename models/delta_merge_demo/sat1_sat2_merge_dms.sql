{{ config(materialized='incremental') }}

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
incremental_delta_check: true
{%  endset  %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ delta_merge_sat(source_models=metadata_dict['source_models'],
                     custom_rsrc=metadata_dict['custom_rsrc'],
                     key_column=metadata_dict['key_column'],
                     incremental_delta_check=metadata_dict['incremental_delta_check'],
                     parent_model=metadata_dict['parent_model']) }}