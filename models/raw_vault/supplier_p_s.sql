{{ config(materialized='view',
          schema='Core') }}

{%- set yaml_metadata -%}
sat_v0: supplier_p0_s
hashkey: hk_supplier_h
hashdiff: hd_supplier_p_s
add_is_current_flag: true
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v1(sat_v0=metadata_dict['sat_v0'],
                     hashkey=metadata_dict['hashkey'],
                     hashdiff=metadata_dict['hashdiff'],
                     add_is_current_flag=metadata_dict['add_is_current_flag']) }}