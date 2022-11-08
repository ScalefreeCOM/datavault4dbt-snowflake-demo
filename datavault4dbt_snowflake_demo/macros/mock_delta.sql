{%- macro mock_delta(source_relation, number_of_deltas, business_key_column, relationship_columns, date_column, start_date='2022-10-01T07:00:00', initial_split_percentage=50) -%}

{{ log('bk: '~business_key_column, true)}}

{%- set all_source_columns = adapter.get_columns_in_relation(source_relation) -%}

WITH  random_columns AS 
( 
    SELECT {{ dbt_utils.star(source_relation) }},
     uniform(1, 100, random()) as random_nr 
    FROM {{ source_relation }}
),

initial_batch AS (
SELECT
    {{ dbt_utils.star(source_relation) }},
    TO_TIMESTAMP('{{ start_date }}', 'YYYY-MM-DDTHH24:MI:SS') as edwLoadDate
FROM random_columns
WHERE random_nr > {{ initial_split_percentage }}
), 

{%- for i in range(1, number_of_deltas) -%}

{%- set random_nr = range(1, initial_split_percentage) | random -%}

{%- set new_records_random_nr = range(1, initial_split_percentage) | random %}
{%- set upd_descr_attr_random_nr = range(initial_split_percentage, 100) | random %}
{%- set upd_relations_random_nr = range(upd_descr_attr_random_nr, 100) | random %}
{%- set duplicates_random_nr = range(upd_relations_random_nr, 100) | random %}

increment_{{ i }} AS (

--New Records
SELECT 
    {{ dbt_utils.star(source_relation) }},
    TIMESTAMPADD(DAY, {{ i }}, TO_TIMESTAMP('{{ start_date }}', 'YYYY-MM-DDTHH24:MI:SS')) as edwLoadDate
FROM random_columns
WHERE random_nr between {{ new_records_random_nr }} and {{ initial_split_percentage }}

UNION ALL
    
--Updated Records (Updated Descriptive Attributes)
SELECT 
    {% for column in all_source_columns %}
        {% if column.name|upper != business_key_column|upper and (column.name|upper not in relationship_columns|map('upper') ) and column.dtype == 'VARCHAR'  -%}
        CONCAT({{ column.name }}, '_{{ i }}' ) as {{ column.name }},
        {% else -%}
        {{ column.name }},
        {% endif %}
    {% endfor %}
    TIMESTAMPADD(DAY, {{ i }}, TO_TIMESTAMP('{{ start_date }}', 'YYYY-MM-DDTHH24:MI:SS')) as edwLoadDate
FROM random_columns
WHERE random_nr between {{ initial_split_percentage }} and {{ upd_descr_attr_random_nr }} 
    
UNION ALL
    
--Updated Records (Updated Relationships)
SELECT 
    {% for column in all_source_columns %}
        {% if column.name|upper in relationship_columns|map('upper') -%}
        LEAD({{ column.name }}) OVER (ORDER BY {{ date_column }}) as {{ column.name }},
        {% else -%}
        {{ column.name }},
        {% endif -%}
    {% endfor -%}
    TIMESTAMPADD(DAY, {{ i }}, TO_TIMESTAMP('{{ start_date }}', 'YYYY-MM-DDTHH24:MI:SS')) as edwLoadDate
FROM random_columns
WHERE random_nr between {{ upd_descr_attr_random_nr }}  and {{ upd_relations_random_nr }} 
    
UNION ALL
    
--Duplicated Records, no updates
SELECT 
    {{ dbt_utils.star(source_relation) }},
    TIMESTAMPADD(DAY, {{ i }}, TO_TIMESTAMP('{{ start_date }}', 'YYYY-MM-DDTHH24:MI:SS')) as edwLoadDate
FROM random_columns
WHERE random_nr between {{ upd_relations_random_nr }}  and 100
),
{%- endfor -%}

Unionized as (
    SELECT * FROM initial_batch
    UNION ALL
    {% for i in range(1, number_of_deltas) %}
    SELECT * FROM increment_{{ i }}
    {% if not loop.last %} UNION ALL {% endif %}
    {% endfor %}
)

SELECT * FROM unionized
{%- endmacro -%}