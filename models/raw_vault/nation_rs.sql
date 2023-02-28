{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_model: stg_nation
parent_ref_keys: N_NATIONKEY
src_hashdiff: hd_nation_rs
src_payload:
    - N_COMMENT
    - N_NAME
    - N_REGIONKEY
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.ref_sat_v0(source_model=metadata_dict['source_model'],
                     parent_ref_keys=metadata_dict['parent_ref_keys'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}