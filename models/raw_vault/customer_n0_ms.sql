{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_model: 'stg_order_ma'
parent_hashkey: 'hk_customer_h'
src_hashdiff: 'hd_customer_n_ms'
src_ma_key: 'o_orderkey'
src_payload: 
    - o_orderstatus
    - o_orderpriority
    - o_clerk
    - o_shippriority
    - o_comment
    - legacy_orderkey
{%- endset -%}

{{ datavault4dbt.ma_sat_v0(yaml_metadata=yaml_metadata) }}


