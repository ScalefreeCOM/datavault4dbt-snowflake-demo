{{ config(schema='turbovault_rdv',
           materialized='incremental',
           unique_key=['hk_orders_h', 'hd_orders_tpch_n_s', 'GETDATE()']) }} 

{%- set yaml_metadata -%}
source_model: "orders" 
parent_hashkey: "hk_orders_h"
src_hashdiff: 'hd_orders_tpch_n_s'
src_payload: 
  - o_orderstatus
  - o_totalprice
  - o_orderdate
  - o_orderpriority
  - o_clerk
  - o_shippriority
  - o_comment

{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.sat_v0(parent_hashkey=metadata_dict["parent_hashkey"],
                src_hashdiff=metadata_dict["src_hashdiff"],
                src_payload=metadata_dict["src_payload"],
                source_model=metadata_dict["source_model"])   }}