{{ config(materialized='view') }}
{{ config(schema='turbovault_stage') }}

{%- set yaml_metadata -%}
source_model: 
  'TPC-H_SF1': 'Nation'
hashed_columns:
  hk_nation_h:
    - N_NATIONKEY
  hk_region_h:
    - N_REGIONKEY
  hk_nation_region_tpch_l:
    - N_NATIONKEY
    - N_REGIONKEY
  hd_nation_tpch_n_s:
    is_hashdiff: true
    columns:
      - N_COMMENT
      - N_NAME

rsrc: '!Nation' 
ldts: 'GETDATE()'
include_source_columns: true

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.stage(include_source_columns=metadata_dict['include_source_columns'],
                  source_model=metadata_dict['source_model'],
                  hashed_columns=metadata_dict['hashed_columns'],
                  rsrc=metadata_dict['rsrc'],
                  ldts=metadata_dict['ldts'],
                  prejoined_columns=metadata_dict['prejoined_columns']) }}