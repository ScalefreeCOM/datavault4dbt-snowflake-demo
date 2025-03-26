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

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}