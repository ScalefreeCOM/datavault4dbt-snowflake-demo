{{ config(materialized='view') }}
{{ config(schema='turbovault_stage') }}

{%- set yaml_metadata -%}
source_model: 
  'TPC-H_SF1': 'Part'
hashed_columns:
  hk_part_h:
    - P_PARTKEY
  hd_part_tpch_n_s:
    is_hashdiff: true
    columns:
      - P_BRAND
      - P_COMMENT
      - P_CONTAINER
      - P_MFGR
      - P_NAME
      - P_RETAILPRICE
      - P_SIZE
      - P_TYPE

rsrc: '!Part' 
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