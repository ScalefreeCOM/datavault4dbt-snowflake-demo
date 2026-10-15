{#-
    Generic helper for SCD-2 style delta checking with manual hash column list.

    Behavior:
      - Always builds an internal with_hash_diff CTE
      - Always computes hash_diff and row_number (rn)
      - Always deduplicates consecutive equal hash_diff rows per key ordered by ldts
      - On incremental runs, removes first row if hash_diff is already latest in target table
      - hash_diff_input_columns are selected for payload output
      - all hashed columns are always included in output

    Required arguments:
      - source_alias: name of upstream CTE/alias (string), e.g. 'transformed'
      - key_column: business key column name (string), e.g. 'hk_kunde_h'
      - hash_diff_input_columns: explicit list of columns used to compute hash_diff (list)

    Optional arguments:
      - ldts_column: timestamp column used for ordering (default: 'ldts')
      - hashdiff_column: output hash column name (default: 'hash_diff')
      - rownum_column: technical row-number column name (default: 'rn')
      - pass_through_columns: additional columns to include in the final SELECT
            that are NOT part of the hash_diff computation (default: [])
-#}

{%- macro incremental_delta_check(
    source_alias,
    key_columns,
    hash_diff_input_columns,
    ldts_column='ldts',
    hashdiff_column='hash_diff',
    rownum_column='rn',
    pass_through_columns=[]
) -%}

    {%- if hash_diff_input_columns is not defined or hash_diff_input_columns is none or (hash_diff_input_columns | length) == 0 -%}
        {{ exceptions.raise_compiler_error("incremental_delta_check: 'hash_diff_input_columns' must be provided as a non-empty list.") }}
    {%- endif -%}

    {%- set ns = namespace(output_columns=[], hd_input_columns=[], kc=[]) -%}

    {# normalize key_column to a list (supports single key string or list of keys) #}
    {%- if key_columns is defined and key_columns is not none -%}
        {%- if key_columns is string -%}
            {%- do ns.kc.append(key_columns) -%}
        {%- else -%}
            {%- for k in key_columns -%}
                {%- if k not in ns.kc -%}
                    {%- do ns.kc.append(k) -%}
                {%- endif -%}
            {%- endfor -%}
        {%- endif -%}
    {%- endif -%}

    {%- if (ns.kc | length) == 0 -%}
        {{ exceptions.raise_compiler_error("incremental_delta_check: 'key_columns' must be provided as a string or non-empty list.") }}
    {%- endif -%}

    {%- for col in hash_diff_input_columns -%}
        {%- if col not in ns.kc and col != ldts_column and col != hashdiff_column and col != rownum_column and col not in ns.output_columns -%}
            {%- do ns.output_columns.append(col) -%}
        {%- endif -%}
    {%- endfor -%}

    {# We expect a CDC_OPERATION column in all sources. We normalise to 'D' for any
       delete-style operation (the standard 'D' AND the non-standard 'Delete' string
       that some source systems emit), and to 'U' for everything else so that
       create ('C') / update ('U') are treated as equivalent in the hash. Without
       the 'Delete' branch a transition Delete → C with unchanged payload would map
       both rows to 'U', make the hashes equal, and cause the qualify clause to
       eliminate the 'C' row. #}
    {%- for col in hash_diff_input_columns -%}
        {%- if col not in ns.kc and col != ldts_column and col != hashdiff_column and col != rownum_column and col not in ns.hd_input_columns -%}
            {%- if col == 'CDC_OPERATION' or col == 'cdc_operation' -%}
                {%- do ns.hd_input_columns.append("iff(lower(" ~ col ~ ") in ('d', 'delete'), 'D', 'U')") -%}
            {%- else -%}
                {%- do ns.hd_input_columns.append(col) -%}
            {%- endif -%}
        {%- endif -%}
    {%- endfor -%}

with_hash_diff as (
    select
        src.{{ ldts_column }} as {{ ldts_column }},
        {%- for k in ns.kc %}
        src.{{ k }} as {{ k }},
        {%- endfor %}
        {{ datavault4dbt.hash(columns=ns.hd_input_columns, alias=hashdiff_column) }}
        {%- for col in ns.output_columns %},
        src.{{ col }} as {{ col }}
        {%- endfor %}
        {%- for col in pass_through_columns %},
        src.{{ col }} as {{ col }}
        {%- endfor %},
        row_number() over (
            partition by {% for k in ns.kc %}src.{{ k }}{% if not loop.last %}, {% endif %}{%- endfor %}
            order by src.{{ ldts_column }}
        ) as {{ rownum_column }}
    from {{ source_alias }} src
    qualify
        case
            when {{ hashdiff_column }} = lag({{ hashdiff_column }}) over (
                partition by {% for k in ns.kc %}src.{{ k }}{% if not loop.last %}, {% endif %}{%- endfor %}
                order by src.{{ ldts_column }}
            )
            then false
            else true
        end
)

{%- if is_incremental() %}
, latest_existing as (
    select
        {%- for k in ns.kc %}
        {{ k }},
        {%- endfor %}
        {{ hashdiff_column }}
    from {{ this }}
    qualify row_number() over (
        partition by {% for k in ns.kc %}{{ k }}{% if not loop.last %}, {% endif %}{%- endfor %}
        order by {{ ldts_column }} desc
    ) = 1
)
{%- endif %}

select
    {%- for k in ns.kc %}
    {{ k }},
    {%- endfor %}
    {{ ldts_column }},
    {{ hashdiff_column }}
    {%- for col in ns.output_columns %},
    {{ col }}
    {%- endfor %}
    {%- for col in pass_through_columns %},
    {{ col }}
    {%- endfor %}
from with_hash_diff
{%- if is_incremental() %}
where not exists (
    select 1
    from latest_existing le
    where
      {%- for k in ns.kc %}
      with_hash_diff.{{ k }} = le.{{ k }}{% if not loop.last %} and{% endif %}
      {%- endfor %}
      and with_hash_diff.{{ hashdiff_column }} = le.{{ hashdiff_column }}
      and with_hash_diff.{{ rownum_column }} = 1
)
{%- endif %}

{%- endmacro -%}	