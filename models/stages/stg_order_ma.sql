{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Orders'
hashed_columns: 
    hk_customer_h:
        - o_custkey
    hd_customer_n_ms:
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
multi_active_config:
    multi_active_key: o_orderkey
    main_hashkey_column: hk_customer_h 
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}

                    