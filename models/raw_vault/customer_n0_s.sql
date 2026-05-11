{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_customer
parent_hashkey: hk_customer_h
src_hashdiff: hd_customer_n_s
src_payload:
    - c_acctbal
    - c_mktsegment
    - c_comment
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}