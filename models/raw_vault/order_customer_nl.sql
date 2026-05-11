{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_order
link_hashkey: hk_order_customer_nl
foreign_hashkeys: 
    - hk_order_h
    - hk_customer_h
payload:
    - o_totalprice
    - o_orderdate
{%- endset -%}      

{{ datavault4dbt.nh_link(yaml_metadata=yaml_metadata) }}