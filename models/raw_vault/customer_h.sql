{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_customer:
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_order:
        hk_column: hk_customer_h
        bk_columns: o_custkey
        rsrc_static: 'TPC_H_SF1.Orders'
hashkey: hk_customer_h
business_keys: c_custkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}