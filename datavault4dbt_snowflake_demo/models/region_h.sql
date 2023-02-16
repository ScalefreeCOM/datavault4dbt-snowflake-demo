{{ config(schema='turbovault_rdv',
    materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  nation:
    bk_columns: 'N_REGIONKEY'
    rsrc_static: 'Nation'
hashkey: hk_region_h
business_keys: 
  - 'N_REGIONKEY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict["source_models"],
                hashkey=metadata_dict["hashkey"],
                business_keys=metadata_dict["business_keys"]) }} 
