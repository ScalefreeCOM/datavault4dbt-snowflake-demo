{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
tracked_hashkey: hk_customer_h
source_models:
    stg_customer:
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_order:
        hk_column: hk_customer_h
        rsrc_static: 'TPC_H_SF1.Orders'
{%- endset -%}    

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.rec_track_sat(tracked_hashkey=metadata_dict['tracked_hashkey'],
                                source_models=metadata_dict['source_models']) }}