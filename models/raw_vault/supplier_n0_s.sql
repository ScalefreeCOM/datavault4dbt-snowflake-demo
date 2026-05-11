{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_supplier
parent_hashkey: hk_supplier_h
src_hashdiff: hd_supplier_n_s
src_payload:
    - s_acctbal
    - s_comment 
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}