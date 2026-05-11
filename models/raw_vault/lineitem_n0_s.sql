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

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}