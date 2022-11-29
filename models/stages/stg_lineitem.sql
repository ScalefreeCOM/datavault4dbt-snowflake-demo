{{ config(materialized='table', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'LineItem'
hashed_columns: 
    hk_l_lineitem:
        - l_orderkey
        - l_partkey
        - l_suppkey
        - l_linenumber
    hk_h_orders:
        - l_orderkey
    hk_h_parts:
        - l_partkey
    hk_h_suppliers:
        - l_suppkey
ldts: "{{ random_ldts() }}"
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

                    