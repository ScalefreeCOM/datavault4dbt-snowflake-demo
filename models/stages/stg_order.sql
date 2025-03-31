{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Orders'
hashed_columns: 
    hk_order_h:
        - o_orderkey
    hk_customer_h:
        - o_custkey
    hk_order_customer_nl:
        - o_orderkey
        - o_custkey
    hd_order_customer_n_s:
        is_hashdiff: true
        columns:
            - o_orderstatus
            - o_orderpriority
            - o_clerk
            - o_shippriority
            - o_comment
            - legacy_orderkey
missing_columns:
    legacy_orderkey: 'STRING'
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Orders'
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}