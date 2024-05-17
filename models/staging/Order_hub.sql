{{ config(materialized='incremental') }}

{{
    hub_macro(
        business_key="o_orderkey",
        hashkey_name="hk_orders",
        source_model="stg_TPC_H_SF1__Orders",
        record_source="TPCH_Orders"
    )
}}
