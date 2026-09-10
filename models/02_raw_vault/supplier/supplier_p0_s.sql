{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_supplier
parent_hashkey: hk_supplier_h
src_hashdiff: hd_supplier_p_s
src_payload:
    - s_name
    - s_address
    - s_phone
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}