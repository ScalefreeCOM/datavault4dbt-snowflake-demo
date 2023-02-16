{{ config(materialized='view') }}
{{ config(schema='turbovault_stage') }}

{%- set yaml_metadata -%}
source_model: 
  'TPC-H_SF1': 'Customer'
hashed_columns:
  hk_customer_h:
    - C_CUSTKEY
  hk_nation_h:
    - C_NATIONKEY
  hk_customer_nation_tpch_l:
    - C_CUSTKEY
    - C_NATIONKEY
  hd_customer_tpch_n_s:
    is_hashdiff: true
    columns:
      - C_ACCTBAL
      - C_COMMENT
      - C_MKTSEGMENT
  hd_customer_tpch_p_s:
    is_hashdiff: true
    columns:
      - C_ADDRESS
      - C_NAME
      - C_PHONE

rsrc: '!Customer' 
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