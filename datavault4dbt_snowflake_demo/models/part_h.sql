{{ config(schema='turbovault_rdv',
    materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  part:
    bk_columns: 'P_PARTKEY'
    rsrc_static: 'Part'
hashkey: hk_part_h
business_keys: 
  - 'P_PARTKEY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict["source_models"],
                hashkey=metadata_dict["hashkey"],
                business_keys=metadata_dict["business_keys"]) }} 
