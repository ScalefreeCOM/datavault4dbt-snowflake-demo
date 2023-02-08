{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'deltas': 'orders_delta'
hashed_columns: 
    hk_h_orders:
        - o_orderkey
    hk_h_customers:
        - customer_name
    hk_l_orders_customers:
        - o_orderkey
        - customer_name
    hd_orders_n_s:
        is_hashdiff: true
        columns:
            - o_orderstatus
            - o_totalprice
            - o_orderdate
            - o_orderpriority
            - o_clerk
            - o_shippriority
            - o_comment
            - is_highest_priority
            - description
            - legacy_orderkey
derived_columns:
    is_highest_priority:
        value: "CASE WHEN (o_orderpriority = '1 - URGENT') THEN true ELSE false END"
        datatype: "BOOLEAN"
        src_cols_required: 'o_orderpriority'
    description:
        value: '!Orders from TPC_H, reference to Customers.'
        datatype: 'STRING'
    test:
        value: "o_orderpriority || o_orderpriority"
        datatype: 'STRING'
        src_cols_required: 'o_orderpriority'
    orderkey_string: 
        value: "TO_VARCHAR(o_orderkey)"
        datatype: 'STRING'
        src_cols_required: 'o_orderkey'
missing_columns:
    legacy_orderkey: 'STRING'
prejoined_columns:
    customer_name:
        src_name: 'TPC-H_SF1'
        src_table: 'Customer'
        bk: 'c_name'
        this_column_name: 'o_custkey'
        ref_column_name: 'c_custkey'
ldts: 'edwLoadDate'
rsrc: '!TPC_H_SF1.Orders'
{%- endset -%}

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.stage(source_model=metadata_dict['source_model'],
                    ldts=metadata_dict['ldts'],
                    rsrc=metadata_dict['rsrc'],
                    hashed_columns=metadata_dict['hashed_columns'],
                    derived_columns=metadata_dict['derived_columns'],
                    missing_columns=metadata_dict['missing_columns'],
                    prejoined_columns=metadata_dict['prejoined_columns'],
                    include_source_columns=true) }}

                    