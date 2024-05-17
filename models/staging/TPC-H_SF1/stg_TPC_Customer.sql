{{ config(materialized='table') }}

with 

source as (

    select * from {{ source('TPC-H_SF1', 'Customer') }}

),

renamed as (

    select
        c_custkey,
        c_name,
        c_address,
        c_nationkey,
        c_phone,
        c_acctbal,
        c_mktsegment,
        c_comment

    from source

)

select * from renamed
