{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Region'
hashed_columns:
    hd_region_rs:
        is_hashdiff: true
        columns:
            - R_COMMENT
            - R_NAME
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Region'
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

                    
                    