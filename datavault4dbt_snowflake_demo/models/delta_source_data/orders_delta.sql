{{ config(materialized='view', schema='source_data') }}

SELECT * FROM {{ source('deltas', 'orders_source_data') }}