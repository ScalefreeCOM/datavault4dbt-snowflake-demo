{{ config(materialized='incremental') }}

{%- set yaml_metadata -%}
start_date: '2015-01-01'
daily_snapshot_time: '07:30:00'
{%- endset -%}    

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{%- set start_date = metadata_dict['start_date'] -%}
{%- set daily_snapshot_time = metadata_dict['daily_snapshot_time'] -%}

{{ datavault4dbt.control_snap_v0(start_date=start_date,
                                daily_snapshot_time=daily_snapshot_time) }}     