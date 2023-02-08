{{ config(materialized='view', schema='source_data') }}

SELECT * FROM {{ ref('orders_source_data') }} WHERE edwLoadDate = TO_TIMESTAMP('2022-10-01T07:00:00', 'YYYY-MM-DDTHH24:MI:SS')