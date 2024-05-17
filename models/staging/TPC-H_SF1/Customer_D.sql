{{ config(materialized='incremental') }}


SELECT
    *
FROM {{ ref('stg_TPC_Customer') }} stg

{% if is_incremental() %}
WHERE NOT EXISTS 
    (SELECT 1 FROM {{ this }} t WHERE stg.c_custkey = t.c_custkey)

{% endif %}