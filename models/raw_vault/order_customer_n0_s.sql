{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: stg_order
parent_hashkey: hk_order_customer_nl
src_hashdiff: hd_order_customer_n_s
src_payload:
    - o_orderstatus
    - o_orderpriority
    - o_clerk
    - o_shippriority
    - o_comment
    - legacy_orderkey
{%- endset -%}      

{{ datavault4dbt.sat_v0(yaml_metadata=yaml_metadata) }}