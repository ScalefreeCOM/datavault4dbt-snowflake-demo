{{ config(schema='turbovault_rdv',
          materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  customer:
    fk_columns: 
      - 'hk_customer_h'
      - 'hk_nation_h'
    rsrc_static: 'Customer'
link_hashkey: hk_customer_nation_tpch_l 
foreign_hashkeys: 
  - 'hk_customer_h'
  - 'hk_nation_h'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.link(source_models=metadata_dict['source_models'],
        link_hashkey=metadata_dict['link_hashkey'],
        foreign_hashkeys=metadata_dict['foreign_hashkeys']
        )}}