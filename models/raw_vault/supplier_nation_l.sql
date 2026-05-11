{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_supplier
link_hashkey: hk_supplier_nation_l
foreign_hashkeys: 
    - hk_supplier_h
    - hk_nation_h
{%- endset -%}      

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}