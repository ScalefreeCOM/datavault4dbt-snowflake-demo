{{ config(materialized='incremental',
          post_hook="{{ datavault4dbt.clean_up_pit('snap_v1') }}") }}

{%- set yaml_metadata -%}
tracked_entity: supplier_h
hashkey: 'hk_supplier_h'
sat_names:
    - supplier_n_s
    - supplier_p_s
snapshot_relation: 'snap_v1'
snapshot_trigger_column: 'is_active'
dimension_key: 'hk_supplier_d'
{%- endset -%}    

{{ datavault4dbt.pit(yaml_metadata=yaml_metadata) }}