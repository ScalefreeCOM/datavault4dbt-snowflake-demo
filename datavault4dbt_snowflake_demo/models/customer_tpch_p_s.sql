{{ config(schema='turbovault_rdv',
           materialized='view') }} 

{%- set yaml_metadata -%}
sat_v0: 'customer_tpch_p0_s'
hashkey: "hk_customer_h"
hashdiff: 'hd_customer_tpch_p_s'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v1(sat_v0=metadata_dict['sat_v0'],
          hashkey=metadata_dict['hashkey'],
          hashdiff=metadata_dict['hashdiff'],
          ledts_alias=none) }}