{{ config(materialized='table', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Customer'
hashed_columns: 
    hk_h_customer:
        - c_custkey
    hk_h_nation:
        - c_nationkey
    hk_l_customer_nation:
        - c_custkey
        - c_nationkey
    hd_customer_n_s:
        is_hashdiff: true
        columns:
            - c_name
            - c_address
            - c_phone
    hd_customer_p_s:
        is_hashdiff: true
        columns:
            - c_acctbal
            - c_mktsegment
            - c_comment
ldts: "{{ random_ldts() }}"
rsrc: '!TPC_H_SF1.Customer'
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

                    