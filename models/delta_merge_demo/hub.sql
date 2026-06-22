{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
business_keys:
- src1_bk
hashkey: hk1
source_models:
  stg1:
    bk_columns:
    - src1_bk::VARCHAR 
    rcsrc_static: SRC1
  stg2:
    bk_columns:
    - src1_bk::VARCHAR 
    rcsrc_static: SRC1

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict['source_models'],
                     hashkey=metadata_dict['hashkey'],
                     business_keys=metadata_dict['business_keys']) }}
