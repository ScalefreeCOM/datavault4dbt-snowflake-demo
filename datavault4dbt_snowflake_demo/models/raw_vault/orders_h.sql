{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
  - name: stg_orders
    hk_column: hk_h_orders
    bk_columns: orderkey_string
  - name: stg_orders
    hk_column: hk_h_customers
    bk_columns: customer_name
hashkey: hk_h_orders
business_keys: o_orderkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}