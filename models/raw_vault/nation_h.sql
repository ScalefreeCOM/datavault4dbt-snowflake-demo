{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    stg_nation:
        rsrc_static: 'TPC_H_SF1.Nation'
    stg_customer:
        bk_columns: c_nationkey
        rsrc_static: 'TPC_H_SF1.Customer'
hashkey: hk_nation_h
business_keys: n_nationkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}