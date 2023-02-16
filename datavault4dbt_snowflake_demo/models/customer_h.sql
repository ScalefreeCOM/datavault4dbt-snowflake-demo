{{ config(schema='turbovault_rdv',
    materialized='incremental') }}

{%- set yaml_metadata -%}
source_models: 
  customer:
    bk_columns: 'C_CUSTKEY'
    rsrc_static: 'Customer'
  orders:
    bk_columns: 'O_CUSTKEY'
    rsrc_static: 'Orders'
hashkey: hk_customer_h
business_keys: 
  - 'C_CUSTKEY'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ datavault4dbt.hub(source_models=metadata_dict["source_models"],
                hashkey=metadata_dict["hashkey"],
                business_keys=metadata_dict["business_keys"]) }} 
