{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Orders'
hashed_columns: 
    hk_order_h:
        - o_orderkey
    hk_customer_h:
        - o_custkey
    hk_order_customer_l:
        - o_orderkey
        - o_custkey
    hd_order_n_s:
        is_hashdiff: true
        columns:
            - o_orderstatus
            - o_totalprice
            - o_orderdate
            - o_orderpriority
            - o_clerk
            - o_shippriority
            - o_comment
            - legacy_orderkey
            - customer_name
missing_columns:
    legacy_orderkey: 'STRING'
prejoined_columns:
    customer_name:
        src_name: 'TPC-H_SF1'
        src_table: 'Customer'
        bk: 'C_Name'
        this_column_name: 'o_custkey'
        ref_column_name: 'c_custkey'
    customer_name_ref: 
        ref_model: 'stg_customer'
        bk: 'C_Name'
        this_column_name: 
            - 'o_custkey'
            - 'o_custkey'
        ref_column_name: 
            - 'c_custkey'
            - 'c_custkey'
ldts: "SYSDATE()"
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

                    