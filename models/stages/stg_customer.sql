{{ config(materialized='view', 
            schema='Stage') }}

{%- set yaml_metadata -%}
source_model:
    'bikes': 'customers_raw'
derived_columns:
    date_of_birth:
        value: "TO_TIMESTAMP(dob, 'YYYY-MM-DD')"
        datatype: TIMESTAMP
hashed_columns: 
    hk_customer_h:
        - customer_id
    hd_customer_p_s:
        is_hashdiff: true
        columns:
            - name
            - date_of_birth
            - age
    hd_customer_n_s:
        is_hashdiff: true
        columns:
            - gender
            - past_3_years_bike_related_purchases
            - job_title
            - job_industry_category
            - wealth_segment
            - deceased_indicator
            - owns_car
            - tenure
ldts: "SYSDATE()"
rsrc: '!bikes.Customers'
{%- endset -%}

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.stage(source_model=metadata_dict['source_model'],
                    ldts=metadata_dict['ldts'],
                    rsrc=metadata_dict['rsrc'],
                    hashed_columns=metadata_dict['hashed_columns'],
                    derived_columns=metadata_dict['derived_columns'],
                    missing_columns=none,
                    prejoined_columns=none,
                    include_source_columns=true) }}

                    