{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_customer
parent_hashkey: hk_customer_h
src_hashdiff: hd_customer_p_s
src_payload:
    - c_name
    - c_address
    - c_phone
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}