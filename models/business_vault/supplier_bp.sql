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

{%- set metadata_dict = fromyaml(yaml_metadata) -%}

{{ datavault4dbt.pit(pit_type=metadata_dict['pit_type'],
                                tracked_entity=metadata_dict['tracked_entity'],
                                hashkey=metadata_dict['hashkey'],
                                sat_names=metadata_dict['sat_names'],
                                snapshot_relation=metadata_dict['snapshot_relation'],
                                snapshot_trigger_column=metadata_dict['snapshot_trigger_column'],
                                dimension_key=metadata_dict['dimension_key'],
                                custom_rsrc=metadata_dict['custom_rsrc']) }}