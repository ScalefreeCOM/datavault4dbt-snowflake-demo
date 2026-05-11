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

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}