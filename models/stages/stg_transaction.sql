{{ config(materialized='view', 
            schema='Stages') }}

{%- set yaml_metadata -%}
source_model:
    'bikes': 'transactions_raw'
derived_columns:
    transaction_date_ts:
        value: "TO_TIMESTAMP(transaction_date, 'DD/MM/YYYY')"
        datatype: TIMESTAMP
hashed_columns: 
    hk_transaction_tl:
        - transaction_id
    hk_customer_h:
        - customer_id
    hk_product_h:
        - product_id
    hd_product_n_s:
        is_hashdiff: true
        columns:
            - brand
            - product_line
            - product_class
            - product_size
            - product_first_sold_date
ldts: "SYSDATE()"
rsrc: '!bikes.Transactions'
{%- endset -%}

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.stage(source_model=metadata_dict['source_model'],
                    ldts=metadata_dict['ldts'],
                    rsrc=metadata_dict['rsrc'],
                    hashed_columns=metadata_dict['hashed_columns'],
                    derived_columns=none,
                    missing_columns=none,
                    prejoined_columns=none,
                    include_source_columns=true) }}

                    