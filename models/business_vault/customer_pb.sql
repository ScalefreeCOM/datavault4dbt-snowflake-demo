{{ config(materialized='incremental',
          schema='Core',
          post_hook="{{ datavault4dbt.clean_up_pit('snap_v1') }}") }}

{%- set yaml_metadata -%}
tracked_entity: customer_h
hashkey: 'hk_h_customer'
sat_names:
    - customer_n_s
    - customer_p_s
snapshot_relation: 'snap_v1'
snapshot_trigger_column: 'is_active'
dimension_key: 'hk_customer_d'
{%- endset -%}    

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{%- set pit_type = none -%}
{%- set tracked_entity = metadata_dict['tracked_entity'] -%}
{%- set hashkey = metadata_dict['hashkey'] -%}
{%- set sat_names = metadata_dict['sat_names'] -%}
{%- set snapshot_relation = metadata_dict['snapshot_relation'] -%}
{%- set snapshot_trigger_column = metadata_dict['snapshot_trigger_column'] -%}
{%- set dimension_key = metadata_dict['dimension_key'] -%}
{%- set custom_rsrc = none -%}

{{ datavault4dbt.pit(pit_type=pit_type,
                                tracked_entity=tracked_entity,
                                hashkey=hashkey,
                                sat_names=sat_names,
                                snapshot_relation=snapshot_relation,
                                snapshot_trigger_column=snapshot_trigger_column,
                                dimension_key=dimension_key,
                                custom_rsrc=custom_rsrc) }}