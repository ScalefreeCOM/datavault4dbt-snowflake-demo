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

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.stage(source_model=metadata_dict['source_model'],
                    ldts=metadata_dict['ldts'],
                    rsrc=metadata_dict['rsrc'],
                    hashed_columns=metadata_dict['hashed_columns'],
                    derived_columns=metadata_dict['derived_columns'],
                    missing_columns=metadata_dict['missing_columns'],
                    prejoined_columns=metadata_dict['prejoined_columns'],
                    include_source_columns=true) }}

                    