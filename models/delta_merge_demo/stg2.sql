{%- set yaml_metadata -%}
hashed_columns:
  hd:
    columns:
    - phone
    - cdc_operation
    is_hashdiff: true
  hk1:
    - SRC1_BK
ldts: ldts
rsrc: '!SRC2'
source_model:
  SOURCE_TEST: source2

{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}
