{{ config(materialized='incremental') }}

WITH source_data AS (

    SELECT
        MD5(c_custkey) as hk_customer,
        c_custkey,
        GETDATE() as load_date,
        'TPCH_Customer' as record_source
    FROM {{ ref('stg_TPC_Customer') }} 

)

SELECT 
    *
FROM source_data sd

{% if is_incremental() %}
WHERE NOT EXISTS 
    (SELECT 1 FROM {{ this }} t WHERE sd.hk_customer = t.hk_customer)
{% endif %}