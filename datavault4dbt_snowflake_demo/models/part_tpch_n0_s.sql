{{ config(schema='turbovault_rdv',
           materialized='incremental',
           unique_key=['hk_part_h', 'hd_part_tpch_n_s', 'GETDATE()']) }} 

{%- set yaml_metadata -%}
source_model: "part" 
parent_hashkey: "hk_part_h"
src_hashdiff: 'hd_part_tpch_n_s'
src_payload: 
  - p_brand
  - p_comment
  - p_container
  - p_mfgr
  - p_name
  - p_retailprice
  - p_size
  - p_type

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(parent_hashkey=metadata_dict["parent_hashkey"],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_payload=metadata_dict["src_payload"],
                source_model=metadata_dict["source_model"])   }}