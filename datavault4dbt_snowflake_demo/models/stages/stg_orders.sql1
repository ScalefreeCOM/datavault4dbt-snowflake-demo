{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'deltas': 'orders_initial'
hashed_columns: 
    hk_:
        - 
    hk_:
        - 
    hk_:
        - 
        - 
    hd_:
        is_hashdiff: true
        columns:
            - 
            - 
            - 
            - 
            - 
            - 
            - 
            - 
            - 
            - 
derived_columns:
    is_highest_priority:
        value: 
        datatype: 
        src_cols_required: 
    description:
        value: 
        datatype: 
missing_columns:
    legacy_orderkey: 
prejoined_columns:
    customer_name:
        src_name: 
        src_table: 
        bk: 
        this_column_name: 
        ref_column_name: 
ldts: 
rsrc: 
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

                    