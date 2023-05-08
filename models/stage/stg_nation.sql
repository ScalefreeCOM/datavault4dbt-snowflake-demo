{%- set yaml_metadata -%}
source_model:
    'TPC-H_SF1': 'Nation'
hashed_columns: 
    hk_nation_h:
        - n_nationkey
    hk_region_h:
        - n_regionkey
    hk_nation_region_l:
        - n_nationkey
        - n_regionkey
    hd_nation_n_s:
        is_hashdiff: true
        columns: 
            - n_name
            - n_comment
ldts: "SYSDATE()"
rsrc: '!TPC_H_SF1.Nation'
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

                    