{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_customers
tracked_hashkey: hk_h_customer
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.rec_track_sat(source_models=metadata_dict['source_models'],
                     tracked_hashkey=metadata_dict['tracked_hashkey']) }}