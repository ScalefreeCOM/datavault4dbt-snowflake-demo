{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_part
parent_hashkey: hk_part_h
src_hashdiff: hd_part_n_s
src_payload:
    - p_name
    - p_mfgr
    - p_brand
    - p_type
    - p_size
    - p_container
    - p_retailprice
    - p_comment
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}