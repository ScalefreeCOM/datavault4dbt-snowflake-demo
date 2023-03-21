{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_lineitem
link_hashkey: hk_lineitem_l
foreign_hashkeys: 
    - hk_orders_h
    - hk_part_h
    - hk_supplier_h
    - l_linenumber
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys']) }}