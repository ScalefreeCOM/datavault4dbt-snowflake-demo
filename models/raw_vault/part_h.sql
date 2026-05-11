{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_part:
        rsrc_static: 'TPC_H_SF1.Part'
    stg_lineitem:
        bk_columns: l_partkey
        rsrc_static: 'TPC_H_SF1.LineItem'
    stg_partsupp:
        bk_columns: ps_partkey
        rsrc_static: 'TPC_H_SF1.Partsupp'
hashkey: hk_part_h
business_keys: p_partkey
{%- endset -%}      

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}