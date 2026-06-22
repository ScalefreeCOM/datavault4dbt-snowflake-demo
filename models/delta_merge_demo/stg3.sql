{%- set yaml_metadata -%}
hashed_columns:
  hd:
    columns:
    - value
    - cdc_operation
    is_hashdiff: true
  hk3:
  - SRC3_BK
ldts: ldts
rsrc: '!SRC3'
source_model:
  SOURCE_TEST: source3

{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}
