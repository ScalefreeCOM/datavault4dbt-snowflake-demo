{%- macro delta_merge_sat(yaml) -%}
    {%- set metadata = fromyaml(yaml) -%}

    {%- if "late_arrival_reprocess_days" in metadata -%}
        {%- set late_arrival_reprocess_days = metadata["late_arrival_reprocess_days"] -%}
    {%- else -%} {%- set late_arrival_reprocess_days = none -%}
    {%- endif -%}

    {#- Normalise the reprocess window: 0 means "no reprocess" (same as unset); negatives are invalid. #}
    {%- if late_arrival_reprocess_days is not none -%}
        {%- if late_arrival_reprocess_days < 0 -%}
            {{ exceptions.raise_compiler_error("late_arrival_reprocess_days must be greater than 0 (got " ~ late_arrival_reprocess_days ~ ").") }}
        {%- elif late_arrival_reprocess_days == 0 -%}
            {%- set late_arrival_reprocess_days = none -%}
        {%- endif -%}
    {%- endif -%}

    {% if "parent_model" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing parent_model in metadata") }}
    {% endif %}

    {% if "key_column" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing key_column in metadata") }}
    {% endif %}

    {% if "source_models" not in metadata %}
        {{ exceptions.raise_compiler_error("Missing source_models in metadata") }}
    {% endif %}

    {% for model_name, model_config in metadata["source_models"].items() %}
        {% if "column_prefix" not in model_config %}
            {{ exceptions.raise_compiler_error("Missing column_prefix for source model '" ~ model_name ~ "' in metadata") }}
        {% endif %}
    {% endfor %}

    {#- A reprocess window must physically clear the trailing window before the append re-derives it, so
        the watermark rewinds and the delta check compares against the true pre-window record instead of a
        later one. reset_recent_load_window decides at hook runtime whether to also reopen the window's
        predecessor ledts intervals (MERGE) or just delete; {{ this }} renders at hook time. #}
    {%- set reprocess_pre_hook = none -%}
    {%- if late_arrival_reprocess_days is not none -%}
        {%- set reprocess_pre_hook = "{{ reset_recent_load_window(this, " ~ late_arrival_reprocess_days ~ ") }}" -%}
    {%- endif -%}

    {{
        config(
            tags=["delta_merge_sat"],
            docs={"node_color": "gold"},
            materialized='incremental',
            pre_hook=([reprocess_pre_hook] if late_arrival_reprocess_days is not none else []),
        )
    }}

    {%- if "ledts" in metadata -%} {%- set ledts = metadata["ledts"] -%}
    {%- else -%} {%- set ledts = None -%}
    {%- endif -%}

    {%- if "custom_rsrc" in metadata -%}
        {%- set custom_rsrc = metadata["custom_rsrc"] -%}
    {%- else -%} {%- set custom_rsrc = None -%}
    {%- endif -%}

    {%- if "incremental_delta_check" in metadata -%}
        {%- set incremental_delta_check = metadata["incremental_delta_check"] -%}
    {%- else -%} {%- set incremental_delta_check = false -%}
    {%- endif -%}

    {{
        datavault4dbt_snowflake_demo.delta_merge_sat_v1_0_0(
            parent_model=metadata["parent_model"],
            key_column=metadata["key_column"],
            source_models=metadata["source_models"],
            ledts=ledts,
            custom_rsrc=custom_rsrc,
            incremental_delta_check=incremental_delta_check,
            late_arrival_reprocess_days=late_arrival_reprocess_days
        )
    }}
{%- endmacro -%}