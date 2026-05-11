{{ config(materialized='view') }}

{%- set yaml_metadata -%}
sat_v0: customer_p0_s
hashkey: hk_customer_h
hashdiff: hd_customer_p_s
add_is_current_flag: true
{%- endset -%}      

{{ datavault4dbt.sat_v1(yaml_metadata=yaml_metadata) }}