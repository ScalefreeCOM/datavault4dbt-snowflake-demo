{{ config(schema='turbovault_rdv',
    materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  customer:
    bk_columns: 'C_NATIONKEY'
    rsrc_static: 'Customer'
  nation:
    bk_columns: 'N_NATIONKEY'
    rsrc_static: 'Nation'
hashkey: hk_nation_h
business_keys: 
  - 'N_NATIONKEY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict["source_models"],
                hashkey=metadata_dict["hashkey"],
                business_keys=metadata_dict["business_keys"]) }} 
