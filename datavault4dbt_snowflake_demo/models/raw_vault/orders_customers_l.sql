{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_orders
link_hashkey: hk_l_orders_customers
foreign_hashkeys: 
    - hk_h_orders
    - hk_h_customers
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys']) }}