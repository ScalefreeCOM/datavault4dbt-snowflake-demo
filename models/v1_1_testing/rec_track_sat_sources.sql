{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    - name: stg_customers
      rsrc_static: 'TPC_H_SF1.Customer'
    - name: stg_suppliers
      hk_column: 'hk_h_supplier'
      rsrc_static: 'TPC_H_SF1.Supplier'
tracked_hashkey: hk_h_customer
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.rec_track_sat(source_models=metadata_dict['source_models'],
                     tracked_hashkey=metadata_dict['tracked_hashkey']) }}