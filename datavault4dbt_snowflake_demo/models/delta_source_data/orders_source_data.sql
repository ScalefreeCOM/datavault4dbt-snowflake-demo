{{ config(materialized='table', schema='source_data') }}

{%- set source_relation = source('TPC-H_SF1', 'Orders') -%}

{{ mock_delta(source_relation=source_relation, number_of_deltas=10, business_key_column='o_orderkey', relationship_columns=['o_custkey'], date_column='o_orderdate', start_date='2022-10-01T07:00:00', initial_split_percentage=50)}}