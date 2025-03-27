{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
    stg_region:
        rsrc_static: 'TPC_H_SF1.Region'
    stg_nation:
        bk_columns: n_regionkey
        rsrc_static: 'TPC_H_SF1.Nation'
hashkey: hk_region_h
business_keys: r_regionkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}