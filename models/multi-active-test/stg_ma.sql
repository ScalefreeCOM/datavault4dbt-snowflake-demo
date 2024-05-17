{{ config(materialized='view') }}
{{ config(schema='Stages') }}

{%- set yaml_metadata -%}
source_model: "ma_test"
hashed_columns: 
  hk_test:
    - hk
  hd_test:
    is_hashdiff: true
    columns:
        - col_a
        - col_b
rsrc: '!ma_sat_test'
ldts: 'ldts'
include_source_columns: true
multi_active_config:
  multi_active_key: 'ma_attribute'
  main_hashkey_column: 'hk_test'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.stage(include_source_columns=metadata_dict['include_source_columns'],
                  source_model=metadata_dict['source_model'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  prejoined_columns=none,
                  derived_columns=none,
                  missing_columns=none,
                  rsrc=metadata_dict['rsrc'],
                  ldts=metadata_dict['ldts'],
                  multi_active_config=metadata_dict['multi_active_config']) }}