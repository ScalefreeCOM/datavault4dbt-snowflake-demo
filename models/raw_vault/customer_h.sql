{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    stg_customers:
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_suppliers:
        hk_column: 'hk_h_supplier'
        bk_columns: s_suppkey
        rsrc_static: 'TPC_H_SF1.Supplier'
hashkey: hk_h_customer
business_keys: c_custkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}