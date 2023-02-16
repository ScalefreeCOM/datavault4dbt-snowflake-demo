{{ config(schema='turbovault_rdv',
           materialized='incremental',
           unique_key=['hk_customer_h', 'hd_customer_tpch_p_s', 'GETDATE()']) }} 

{%- set yaml_metadata -%}
source_model: "customer" 
parent_hashkey: "hk_customer_h"
src_hashdiff: 'hd_customer_tpch_p_s'
src_payload: 
  - c_address
  - c_name
  - c_phone

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(parent_hashkey=metadata_dict["parent_hashkey"],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_payload=metadata_dict["src_payload"],
                source_model=metadata_dict["source_model"])   }}