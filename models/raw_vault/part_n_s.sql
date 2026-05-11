{{ config(materialized='view') }}

{%- set yaml_metadata -%}
sat_v0: part_n0_s
hashkey: hk_part_h
hashdiff: hd_part_n_s
add_is_current_flag: true
{%- endset -%}      

{{ datavault4dbt.sat_v1(yaml_metadata=yaml_metadata) }}