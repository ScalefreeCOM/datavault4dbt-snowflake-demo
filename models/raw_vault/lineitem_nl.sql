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

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.nh_link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys'],
                     payload=metadata_dict['payload']) }}