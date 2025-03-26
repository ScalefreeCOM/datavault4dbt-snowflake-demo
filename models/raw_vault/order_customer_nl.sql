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

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.nh_link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys'],
                     payload=metadata_dict['payload']) }}