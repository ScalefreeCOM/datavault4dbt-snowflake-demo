{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Part'
hashed_columns: 
    hk_part_h:
        - p_partkey
    hd_part_n_s:
        is_hashdiff: true
        columns:
            - p_name
            - p_mfgr
            - p_brand
            - p_type
            - p_size
            - p_container
            - p_retailprice
            - p_comment
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Part'
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}