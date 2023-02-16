{{ config(schema='turbovault_rdv',
           materialized='incremental',
           unique_key=['hk_nation_h', 'hd_nation_tpch_n_s', 'GETDATE()']) }} 

{%- set yaml_metadata -%}
source_model: "nation" 
parent_hashkey: "hk_nation_h"
src_hashdiff: 'hd_nation_tpch_n_s'
src_payload: 
  - n_comment
  - n_name

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(parent_hashkey=metadata_dict["parent_hashkey"],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_payload=metadata_dict["src_payload"],
                source_model=metadata_dict["source_model"])   }}