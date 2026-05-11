{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_region:
        rsrc_static: 'TPC_H_SF1.Region'
    stg_nation:
        bk_columns: n_regionkey
        rsrc_static: 'TPC_H_SF1.Nation'
hashkey: hk_region_h
business_keys: r_regionkey
{%- endset -%}      

{{ datavault4dbt.hub(yaml_metadata=yaml_metadata) }}