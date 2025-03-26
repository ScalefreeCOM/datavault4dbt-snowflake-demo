{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_lineitem
parent_hashkey: hk_lineitem_nl
src_hashdiff: hd_lineitem_n_s
src_payload:
    - l_returnflag
    - l_linestatus
    - l_shipdate
    - l_commitdate
    - l_shipinstruct
    - l_shipmode
    - l_comment
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}