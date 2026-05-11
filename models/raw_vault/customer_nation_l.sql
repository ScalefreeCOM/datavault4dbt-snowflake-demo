{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_customer
link_hashkey: hk_customer_nation_l
foreign_hashkeys: 
    - hk_customer_h
    - hk_nation_h
{%- endset -%}      

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}