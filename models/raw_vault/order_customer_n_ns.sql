{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_model: stg_order
parent_hashkey: hk_order_customer_nl
src_payload:
    - o_orderstatus
    - o_orderpriority
    - o_clerk
    - o_shippriority
    - o_comment
    - legacy_orderkey
{%- endset -%}      

{{ datavault4dbt.nh_sat(yaml_metadata=yaml_metadata) }}