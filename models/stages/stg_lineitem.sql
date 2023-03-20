{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'LineItem'
hashed_columns: 
    hk_lineitem_l:
        - l_orderkey
        - l_partkey
        - l_suppkey
        - l_linenumber
    hk_orders_h:
        - l_orderkey
    hk_parts_h:
        - l_partkey
    hk_suppliers_h:
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

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.stage(source_model=metadata_dict['source_model'],
                    ldts=metadata_dict['ldts'],
                    rsrc=metadata_dict['rsrc'],
                    hashed_columns=metadata_dict['hashed_columns'],
                    derived_columns=none,
                    missing_columns=none,
                    prejoined_columns=none,
                    include_source_columns=true) }}

                    