{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_lineitem
link_hashkey: hk_l_lineitem
foreign_hashkeys: 
    - hk_h_orders
    - hk_h_parts
    - hk_h_suppliers
payload:
    - l_linenumber
    - l_quantity
    - l_extendedprice
    - l_discount
    - l_tax
    - l_returnflag
    - l_linestatus
    - l_shipdate
    - l_commitdate
    - l_receiptdate
    - l_shipinstruct
    - l_shipmode
    - l_comment
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.nh_link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     payload=metadata_dict['payload'],
                     disable_hwm=true,
                     source_is_single_batch=true) }}