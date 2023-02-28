{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_nation
ref_keys: N_NATIONKEY
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.ref_hub(source_models=metadata_dict['source_models'],
                     ref_keys=metadata_dict['ref_keys']) }}