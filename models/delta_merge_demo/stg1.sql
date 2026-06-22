{%- set yaml_metadata -%}
hashed_columns:
  hd:
    columns:
    - name
    - city
    - cdc_operation
    - src3_bk
    is_hashdiff: true
  hk1:
    - src1_bk
  hk3:
    - src3_bk
ldts: ldts
rsrc: '!SRC1'
source_model:
  SOURCE_TEST: source1

{%- endset -%}

{{ datavault4dbt.stage(yaml_metadata=yaml_metadata) }}
