{%-  set yaml_metadata -%}
source_model: sat1_sat2_merge_dms {# not necessary to define an alias. It is "main" by default #}
key_column: hk1 
include:
  - src1_bk
  - name
  - phone
  - src3_bk

relations:
  - relation: sat3
    join_to_alias: main {# optional: default is "main" #}
    from_column: src3_bk {# from this #}
    to_column: src3_bk {# from join_to_alias #}
    include:
      - hk3
      - value
    alias: 'first_relation' {# optional: default is relation name #}
    prefix: 'a_' {# column prefix #}
  - relation: sat3
    join_to_alias: main {# optional: default is "main" #}
    from_column: src3_bk {# from this #}
    to_column: src3_bk {# from join_to_alias #}
    include:
      - hk3
      - value
    alias: 'second_relation' {# optional: default is relation name #}
    prefix: 'b_' {# column prefix #}
{%  endset  %}

{{ delta_merge_brg(yaml_metadata) }}