{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_model: stg_lineitem
parent_hashkey: hk_l_lineitem
src_payload:
    - l_extendedprice
    - l_discount
    - l_tax
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.nh_sat(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_payload=metadata_dict['src_payload'],
                     source_is_single_batch=true) }}