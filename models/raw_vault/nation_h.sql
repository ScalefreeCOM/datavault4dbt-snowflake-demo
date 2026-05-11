{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_nation:
        rsrc_static: 'TPC_H_SF1.Nation'
    stg_customer:
        bk_columns: c_nationkey
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_supplier:
        bk_columns: s_nationkey
        rsrc_static: 'TPC_H_SF1.Supplier'
hashkey: hk_nation_h
business_keys: n_nationkey
{%- endset -%}      

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}