{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
parent_hashkey: hk1
source_model: stg2
src_hashdiff: hd
src_payload:
    - phone
    - cdc_operation
    - src1_bk

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}