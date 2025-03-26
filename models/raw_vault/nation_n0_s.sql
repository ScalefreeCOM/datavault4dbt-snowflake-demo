{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_nation
parent_hashkey: hk_nation_h
src_hashdiff: hd_nation_n_s
src_payload:
    - n_name
    - n_comment
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}