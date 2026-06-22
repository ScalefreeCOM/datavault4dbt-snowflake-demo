{#- Simple macro for getting changes for all columns in include with optional expire-creation and filtering #}
{% macro get_changes(
    relation, key_column_name, include, filter=none, calculate_expire=false, dependent_child_key=none
) %}

{%- set end_of_all_times = datavault4dbt.end_of_all_times() -%}

    with
        cte_distinct as (
            select
                {{ key_column_name }}
                {%- for column in include if column | lower != key_column_name | lower -%}
                    ,{{ column }}
                {%- endfor -%},
                hash(
                    {%- for column in include -%}
                        coalesce(rtrim(cast({{ column }} as string)), 'N/A') || '#~!'
                        {%- if not loop.last -%} || {%- endif -%}
                    {%- endfor -%}
                    {#- Must indicate change if the row is deleted (handle both the standard 'D'
                        and the non-standard 'Delete' string that some source systems emit) #}
                    || iff(lower(s.cdc_operation) in ('d', 'delete'), 'D', 'U')
                ) as grm_chksum,
                ldts,
                cdc_operation

            from {{ relation }} s
            where 1 = 1 {%- if filter -%} and {{ filter }} {%- endif -%}
            {#- This will not work when used in other macros! #}
            {# {{-
                    dbt_sb1_sn_macros.generate_incremental_clause(
                        this, "LOAD_DATETIME", use_and=true
                    )
                }} #}
            qualify
                grm_chksum is distinct from lag(grm_chksum) over (
                    {#- Partition by both key and optionally dependent_child_key. Dependent_child_key must be handled manually outside. #}
                    partition by
                        {{ key_column_name }}
                        {% if dependent_child_key %}
                            , {{ dependent_child_key | join(", ") }}
                        {% endif %}
                    order by s.ldts
                )
        ),
        cte_expire as (
            select
                s.*
                {% if calculate_expire %}
                    ,
                    lead(
                        ldts,
                        1,
                        '{{ end_of_all_times }}'::timestamp_ntz(9)
                    ) over (
                        partition by {{ key_column_name }}
                        order by ldts
                    ) as ledts
                {% endif %}
            from cte_distinct s
        )

    select * exclude (grm_chksum)
    from cte_expire s
{% endmacro %}