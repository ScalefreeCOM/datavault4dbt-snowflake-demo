{%- macro delta_merge_brg(yaml) -%}
    {%- set metadata = fromyaml(yaml) -%}

    {% if "source_model" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing source_model in metadata") }}
    {% endif %}
    
    {% if "key_column" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing key_column in metadata") }}
    {% endif %}

    {% if "include" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing include in metadata") }}
    {% endif %}

    {% if "relations" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing relations in metadata") }}
    {% endif %}

    {% for rel in metadata["relations"] %}
        {% if "from_column" not in rel %}
            {{ exceptions.raise_compiler_error("Missing from_column of model " ~ rel.get("relation", "unknown")) }}
        {% endif %}
        {% if "to_column" not in rel %}
            {{ exceptions.raise_compiler_error("Missing to_column of model " ~ rel.get("relation", "unknown")) }}
        {% endif %}
    {% endfor %}
    

    {{
        config(
            tags=["delta_merge_brg"],
            docs={"node_color": "HotPink"},
            materialized='incremental',
        )
    }}

    {{
        datavault4dbt_snowflake_demo.delta_merge_brg_v3_0_0(
            source_model=metadata["source_model"],
            include=metadata["include"],
            key_column=metadata["key_column"],
            prefix=metadata["prefix"],
            relations=metadata["relations"]
        )
    }}
{%- endmacro -%}