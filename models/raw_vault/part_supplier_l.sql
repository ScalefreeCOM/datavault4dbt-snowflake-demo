{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: stg_partsupp
link_hashkey: hk_part_supplier_l
foreign_hashkeys: 
    - hk_part_h
    - hk_supplier_h
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys']) }}