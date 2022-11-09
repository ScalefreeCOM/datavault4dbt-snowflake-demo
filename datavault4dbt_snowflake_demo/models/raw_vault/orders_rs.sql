{{ config(materialized='incremental',
          schema='core') }}

{%- set yaml_metadata -%}
tracked_hashkey: hk_h_orders
source_models: stg_orders
{%- endset -%}    

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.rec_track_sat(tracked_hashkey=metadata_dict['tracked_hashkey'],
                                source_models=metadata_dict['source_models']) }}