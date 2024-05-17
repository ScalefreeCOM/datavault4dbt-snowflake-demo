{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
tracked_hashkey: hk_h_customer
source_models:
    stg_customers:
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_suppliers:
        hk_column: hk_h_supplier
        rsrc_static: 'TPC_H_SF1.Supplier'
{%- endset -%}    

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.rec_track_sat(tracked_hashkey=metadata_dict['tracked_hashkey'],
                                source_models=metadata_dict['source_models'], 
                                disable_hwm=false) }}