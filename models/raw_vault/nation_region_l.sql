{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_nation
link_hashkey: hk_nation_region_l
foreign_hashkeys: 
    - hk_nation_h
    - hk_region_h
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys']) }}