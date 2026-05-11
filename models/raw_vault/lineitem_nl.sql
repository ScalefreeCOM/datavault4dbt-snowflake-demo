{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_lineitem
link_hashkey: hk_lineitem_nl
foreign_hashkeys: 
    - hk_order_h
    - hk_part_h
    - hk_supplier_h
    - l_linenumber
payload:
    - l_quantity
    - l_extendedprice
    - l_discount
    - l_tax
    - l_receiptdate
{%- endset -%}      

{{ datavault4dbt.nh_link(yaml_metadata=yaml_metadata) }}