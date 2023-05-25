{{ config(materialized='incremental',
          schema='Core') }}

{%- set yaml_metadata -%}
source_models: 
    - name: stg_orders
      link_hk: hk_l_orders_customers
      fk_columns: 
        - hk_h_orders
        - hk_h_customers
      rsrc_static: 'TPC_H_SF1.Orders'
    - name: stg_lineitem
      link_hk: hk_l_lineitem
      fk_columns: 
        - hk_h_orders
        - hk_h_parts
      rsrc_static: 'TPC_H_SF1.LineItem'
      payload: 
        - l_comment
        - l_shipdate
link_hashkey: hk_l_orders_customers
foreign_hashkeys: 
    - hk_h_orders
    - hk_h_customers
payload: 
    - o_comment
    - o_orderdate
{%- endset -%}      

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.nh_link(source_models=metadata_dict['source_models'],
                     link_hashkey=metadata_dict['link_hashkey'],
                     foreign_hashkeys=metadata_dict['foreign_hashkeys'],
                     payload=metadata_dict['payload']) }}