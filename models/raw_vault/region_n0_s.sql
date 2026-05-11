{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_region
parent_hashkey: hk_region_h
src_hashdiff: hd_region_n_s
src_payload:
    - r_name
    - r_comment
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}