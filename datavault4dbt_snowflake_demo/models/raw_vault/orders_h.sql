{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
  stg_orders:
    hk_column: hk_h_orders
    bk_columns: orderkey_string
    rsrc_static: 'TPC_H_SF1.Order'
  stg_customers:
    hk_column: hk_h_customer
    bk_columns: c_name
    rsrc_static: 'TPC_H_SF1.Customer'
hashkey: hk_h_orders
business_keys: orderkey_string
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}