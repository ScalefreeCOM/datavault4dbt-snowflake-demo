{{ config(materialized='view') }}

SELECT
*,
'test' as "test/slash"
FROM {{ source('TPC-H_SF1', 'Orders') }}