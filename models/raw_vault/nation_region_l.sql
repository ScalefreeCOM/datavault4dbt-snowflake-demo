{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_nation
link_hashkey: hk_nation_region_l
foreign_hashkeys: 
    - hk_nation_h
    - hk_region_h
{%- endset -%}      

{{ datavault4dbt.link(yaml_metadata=yaml_metadata) }}