{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_supplier:
        rsrc_static: 'TPC_H_SF1.Supplier'
    stg_partsupp:
        bk_columns: ps_suppkey
        rsrc_static: 'TPC_H_SF1.Partsupp'
hashkey: hk_supplier_h
business_keys: s_suppkey
{%- endset -%}      

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}