{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Partsupp'
hashed_columns: 
    hk_part_h:
        - ps_partkey
    hk_supplier_h:
        - ps_suppkey
    hk_part_supplier_l:
        - ps_partkey
        - ps_suppkey
    hd_part_supplier_n_s:
        is_hashdiff: true
        columns:
            - ps_availqty
            - ps_supplycost
            - ps_comment
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Partsupp'
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}

                    