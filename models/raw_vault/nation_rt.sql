{{ config(schema='core', materialized='incremental') }}

{%- set yaml_metadata -%}
ref_hub: 'nation_rh'
ref_satellites: 
    nation_rs1:
        exclude:
            - N_NAME
historized: 'full'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.ref_table(ref_hub=metadata_dict['ref_hub'],
                     ref_satellites=metadata_dict['ref_satellites'],
                     historized=metadata_dict['historized'],
                     snapshot_relation=metadata_dict['snapshot_relation']) }}