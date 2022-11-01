{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_orders
hashkey: hk_h_orders
business_keys: o_orderkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}