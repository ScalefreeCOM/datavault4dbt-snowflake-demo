{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    stg_orders:
        rsrc_static: 'TPC_H_SF1.Orders'
    stg_lineitem:
        bk_columns: l_orderkey
        rsrc_static: 'TPC_H_SF1.LineItem'
hashkey: hk_orders_h
business_keys: o_orderkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}