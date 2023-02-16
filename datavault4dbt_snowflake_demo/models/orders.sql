{{ config(materialized='view') }}
{{ config(schema='turbovault_stage') }}

{%- set yaml_metadata -%}
source_model: 
  'TPC-H_SF1': 'Orders'
hashed_columns:
  hk_customer_h:
    - O_CUSTKEY
  hk_orders_h:
    - O_ORDERKEY
  hk_orders_customer_tpch_l:
    - O_ORDERKEY
    - O_CUSTKEY
  hd_orders_tpch_n_s:
    is_hashdiff: true
    columns:
      - O_ORDERSTATUS
      - O_TOTALPRICE
      - O_ORDERDATE
      - O_ORDERPRIORITY
      - O_CLERK
      - O_SHIPPRIORITY
      - O_COMMENT

rsrc: '!Orders' 
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