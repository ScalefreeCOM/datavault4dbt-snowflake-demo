{#- Macro to get the row count of a relation, optionally with a filter #}
{#- Used to optimize join order by joining smaller tables first to reduce memory usage in Snowflake #}
{% macro get_row_count(relation, filter=none) %}
    {% if execute %}

        {% set relation_exists = adapter.get_relation(
            database=relation.database,
            schema=relation.schema,
            identifier=relation.identifier
        ) %}

        {% if relation_exists %}

            {% set sql %}
                select count(*) as row_count
                from {{ relation }}
                {% if filter %}
                    where {{ filter }}
                {% endif %}
            {% endset %}
        
            {% set results = run_query(sql) %}
            {% if results %} {% set row = results.columns[0] %} {{ return(row[0]) }}
            {% else %} {{ return(0) }}
            {% endif %}
        {% else %} 
            {{ return(0) }}        
        {% endif %}

    {% else %} 
        {{ return(0) }}
    {% endif %}

{% endmacro %}