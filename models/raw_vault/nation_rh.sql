{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    stg_nation: 
        rsrc_static: 'TPC_H_SF1.Nation'
    stg_customers:
        ref_keys: C_NATIONKEY
        rsrc_static: 'TPC_H_SF1.Customer'
ref_keys: N_NATIONKEY
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.ref_hub(source_models=metadata_dict['source_models'],
                     ref_keys=metadata_dict['ref_keys']) }}