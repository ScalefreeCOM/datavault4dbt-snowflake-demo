{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_customer:
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_order:
        hk_column: hk_customer_h
        bk_columns: o_custkey
        rsrc_static: 'TPC_H_SF1.Orders'
hashkey: hk_customer_h
business_keys: c_custkey
{%- endset -%}      

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}