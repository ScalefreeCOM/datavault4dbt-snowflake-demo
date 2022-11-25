
{{ config(materialized='view',
          schema='core') }}

{%- set yaml_metadata -%}
sat_v0: 'ma_v0_test'
hashkey: 'hk_test'
hashdiff: 'hd_test'
ma_attribute: 'ma_attribute'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.ma_sat_v1(sat_v0=metadata_dict['sat_v0'],
                           hashkey=metadata_dict['hashkey'],
                           hashdiff=metadata_dict['hashdiff'],
                           ma_attribute=metadata_dict['ma_attribute']) }}