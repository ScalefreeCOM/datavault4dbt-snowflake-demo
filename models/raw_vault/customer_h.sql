{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    stg_customer:
        rsrc_static: 'TPC_H_SF1.Customer'
    stg_order:
        hk_column: HK_CUSTOMER_H
        bk_columns: O_CUSTKEY
        rsrc_static: 'TPC_H_SF1.Orders'
hashkey: HK_CUSTOMER_H
business_keys: C_CUSTKEY
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}