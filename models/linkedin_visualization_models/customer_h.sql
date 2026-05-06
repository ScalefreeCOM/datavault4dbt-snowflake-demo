{% set yaml_metadata %}
source_models:
    - name: stg_customer_salesforce
    - name: stg_customer_sap
    - name: stg_customer_shopify
hashkey: hk_customer_h
business_keys:
    - customer_key
{% endset %}

{{ datavault4dbt.hub(yaml_metadata) }}