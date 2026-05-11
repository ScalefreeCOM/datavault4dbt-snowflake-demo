{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_partsupp
link_hashkey: hk_part_supplier_l
foreign_hashkeys: 
    - hk_part_h
    - hk_supplier_h
{%- endset -%}      

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}