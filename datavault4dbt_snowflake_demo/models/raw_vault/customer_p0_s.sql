{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_model: stg_customers
parent_hashkey: hk_h_customer
src_hashdiff: hd_customer_p_s
src_payload:
    - c_acctbal
    - c_mktsegment
    - c_comment
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(source_model=metadata_dict['source_model'],
                     parent_hashkey=metadata_dict['parent_hashkey'],
                     src_hashdiff=metadata_dict['src_hashdiff'],
                     src_payload=metadata_dict['src_payload']) }}