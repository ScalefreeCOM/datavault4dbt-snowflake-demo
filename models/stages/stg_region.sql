{{ config(materialized='view') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Region'
hashed_columns: 
    hk_region_h:
        - r_regionkey
    hd_region_n_s:
        is_hashdiff: true
        columns:
            - r_name
            - r_comment
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Region'
{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}

                    