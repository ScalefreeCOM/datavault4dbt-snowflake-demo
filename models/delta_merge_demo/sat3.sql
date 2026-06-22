{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
parent_hashkey: hk3
source_model: stg3
src_hashdiff: hd
src_payload:
    - value
    - cdc_operation
    - src3_bk

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}