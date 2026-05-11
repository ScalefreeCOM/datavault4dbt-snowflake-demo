{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_nation
parent_hashkey: hk_nation_h
src_hashdiff: hd_nation_n_s
src_payload:
    - n_name
    - n_comment
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}