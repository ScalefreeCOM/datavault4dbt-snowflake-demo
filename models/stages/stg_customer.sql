{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Customer'
hashed_columns: 
    hk_customer_h:
        - c_custkey
    hk_nation_h:
        - c_nationkey
    hk_customer_nation_l:
        - c_custkey
        - c_nationkey
    hd_customer_p_s:
        is_hashdiff: true
        columns:
            - c_name
            - c_address
            - c_phone
    hd_customer_n_s:
        is_hashdiff: true
        columns:
            - c_acctbal
            - c_mktsegment
            - c_comment
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Customer'
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}
                    