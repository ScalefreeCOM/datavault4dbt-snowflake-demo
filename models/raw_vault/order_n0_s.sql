{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_model: stg_order
parent_hashkey: hk_order_h
src_hashdiff: hd_order_n_s
src_payload:
    - o_orderstatus
    - o_totalprice
    - o_orderdate
    - o_orderpriority
    - o_clerk
    - o_shippriority
    - o_comment
    - legacy_orderkey
    - customer_name
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}