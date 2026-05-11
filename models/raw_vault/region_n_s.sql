{{ config(materialized='view') }}

{%- set yaml_metadata -%}
sat_v0: region_n0_s
hashkey: hk_region_h
hashdiff: hd_region_n_s
add_is_current_flag: true
{%- endset -%}      

{{ datavault4dbt.sat_v1(yaml_metadata=yaml_metadata) }}