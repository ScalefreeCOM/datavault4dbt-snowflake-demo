{{ config(schema='turbovault_rdv',
          materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  orders:
    fk_columns: 
      - 'hk_orders_h'
      - 'hk_customer_h'
    rsrc_static: 'Orders'
link_hashkey: hk_orders_customer_tpch_l 
foreign_hashkeys: 
  - 'hk_orders_h'
  - 'hk_customer_h'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.link(source_models=metadata_dict['source_models'],
        link_hashkey=metadata_dict['link_hashkey'],
        foreign_hashkeys=metadata_dict['foreign_hashkeys']
        )}}