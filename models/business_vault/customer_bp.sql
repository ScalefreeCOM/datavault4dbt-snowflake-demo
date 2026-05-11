{{ config(materialized='incremental',
          post_hook="{{ datavault4dbt.clean_up_pit('snap_v1') }}") }}

{%- set yaml_metadata -%}
tracked_entity: customer_h
hashkey: 'hk_customer_h'
sat_names:
    - customer_n_s
    - customer_p_s
snapshot_relation: 'snap_v1'
snapshot_trigger_column: 'is_active'
dimension_key: 'hk_customer_d'
{%- endset -%}    

{{ datavault4dbt.pit(yaml_metadata=yaml_metadata) }}