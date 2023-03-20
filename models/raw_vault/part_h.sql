{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    stg_part:
        rsrc_static: 'TPC_H_SF1.Part'
    stg_lineitem:
        bk_columns: l_partkey
        rsrc_static: 'TPC_H_SF1.LineItem'
    stg_partsupp:
        bk_columns: ps_partkey
        rsrc_static: 'TPC_H_SF1.Partsupp'
hashkey: hk_part_h
business_keys: p_partkey
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}