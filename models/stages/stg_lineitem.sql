{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'LineItem'
hashed_columns: 
    hk_lineitem_nl:
        - l_orderkey
        - l_partkey
        - l_suppkey
        - l_linenumber
    hk_order_h:
        - l_orderkey
    hk_part_h:
        - l_partkey
    hk_supplier_h:
        - l_suppkey
    hd_lineitem_n_s:
        is_hashdiff: true
        columns:
            - l_quantity
            - l_extendedprice
            - l_discount
            - l_tax
            - l_returnflag
            - l_linestatus
            - l_shipdate
            - l_commitdate
            - l_receiptdate
            - l_shipinstruct
            - l_shipmode
            - l_comment
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.LineItem'
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}