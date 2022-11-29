{{ config(materialized='table', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Supplier'
hashed_columns: 
    hk_h_supplier:
        - s_suppkey
    hk_h_nation:
        - s_nationkey
    hk_l_supplier_nation:
        - s_suppkey
        - s_nationkey
    hd_supplier_p_s:
        is_hashdiff: true
        columns:
            - s_name
            - s_address
            - s_phone
    hd_supplier_n_s:
        is_hashdiff: true
        columns:
            - s_acctbal
            - s_comment          
ldts: "{{ random_ldts() }}"
rsrc: '!TPC_H_SF1.Supplier'
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

                    