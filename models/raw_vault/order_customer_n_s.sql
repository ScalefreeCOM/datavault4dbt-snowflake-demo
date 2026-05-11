{{ config(materialized='view') }}

{%- set yaml_metadata -%}
sat_v0: order_customer_n0_s
hashkey: hk_order_customer_nl
hashdiff: hd_order_customer_n_s
add_is_current_flag: true
{%- endset -%}      

{{ datavault4dbt.sat_v1(yaml_metadata=yaml_metadata) }}