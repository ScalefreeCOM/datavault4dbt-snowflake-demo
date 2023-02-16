{{ config(schema='turbovault_rdv',
    materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  orders:
    bk_columns: 'O_ORDERKEY'
    rsrc_static: 'Orders'
hashkey: hk_orders_h
business_keys: 
  - 'O_ORDERKEY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict["source_models"],
                hashkey=metadata_dict["hashkey"],
                business_keys=metadata_dict["business_keys"]) }} 
