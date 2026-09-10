{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_partsupp
parent_hashkey: hk_part_supplier_l
src_hashdiff: hd_part_supplier_n_s
src_payload:
    - ps_availqty
    - ps_supplycost
    - ps_comment
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}