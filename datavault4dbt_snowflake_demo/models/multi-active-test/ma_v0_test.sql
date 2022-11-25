
{{ config(materialized='incremental',
          schema='core') }}

{%- set yaml_metadata -%}
source_model: 'stage_ma_sat_test'
parent_hashkey: 'hk_test'
src_hashdiff: 'hd_test'
src_ma_key: 'ma_attribute'
src_payload: 
    - descriptive_attribute_1
    - descriptive_attribute_2
{%- endset -%}

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.ma_sat_v0(source_model=metadata_dict['source_model'],
                           parent_hashkey=metadata_dict['parent_hashkey'],
                           src_hashdiff=metadata_dict['src_hashdiff'],
                           src_ma_key=metadata_dict['src_ma_key'],
                           src_payload=metadata_dict['src_payload']) }}