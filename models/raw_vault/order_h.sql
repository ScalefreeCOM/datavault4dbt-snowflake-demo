{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_order:
        rsrc_static: 'TPC_H_SF1.Orders'
    stg_lineitem:
        bk_columns: l_orderkey
        rsrc_static: 'TPC_H_SF1.LineItem'
hashkey: hk_order_h
business_keys: o_orderkey
{%- endset -%}      

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}