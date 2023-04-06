{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: stg_transaction
link_hashkey: hk_transaction_tl
foreign_hashkeys: 
    - hk_customer_h
    - hk_product_h
payload:
    - transaction_date
    - online_order
    - order_status
    - list_price
    - standard_cost
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{  datavault4dbt.nh_link(
            link_hashkey=metadata_dict['link_hashkey'],
            foreign_hashkeys=metadata_dict['foreign_hashkeys'],
            payload=metadata_dict['payload'],
            source_models=metadata_dict['source_models']
    )
}}