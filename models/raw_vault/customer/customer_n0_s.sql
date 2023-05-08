{%- set yaml_metadata -%}
source_model: stg_customer
parent_hashkey: hk_customer_h
src_hashdiff: hd_customer_n_s
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