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

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}