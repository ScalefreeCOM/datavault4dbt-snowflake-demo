{#
The delta_merge_sat macro merges multiple satellite tables (SCD2-style history tables) into a single unified timeline per business key. 
Think of it as a Point-in-Time (PIT) table builder that:

- Collects all change timestamps (ldts) across all input satellites for each business key
- Inherits the latest values from each satellite at every point in time — so every output row has a complete set of columns from all satellites
- Deduplicates rows where nothing actually changed (using a hash diff across all included columns)
- Supports incremental loading — only processes new changes since the last run
- Optionally joins a parent model (e.g., a hub or link) to enrich the output with parent columns

In Simple Terms: If you have sat_customer_personal (name, address) and sat_customer_financial (income, credit_score), and they change at different times, 
this macro produces a single table where every row has all columns filled in with the value that was valid at that point in time.

How It Works
The macro performs these steps in order:
- Collects all change timestamps (ldts) across all input satellites for a given business key. If satellite A changes at 10:00 and satellite B changes at 11:00, both timestamps become rows in the output.
- Inherits values forward in time. At each timestamp, the macro carries forward the last known value from each satellite. This ensures every output row has a complete set of columns — even if only one satellite changed at that moment.
- Computes a hash diff across all tracked columns. This hash is used to detect whether a row actually represents a meaningful change.
- Deduplicates consecutive rows with identical hash diffs. If two adjacent rows (by ldts) for the same key have the same hash, the later one is removed — only actual changes survive.
- Supports incremental loading. On incremental runs, only new changes since the last loaded ldts are processed. An optional delta check compares the latest hash diff in the target against the first new row to avoid re-inserting unchanged data.
- Optionally joins a parent model (e.g., a hub or link) via an inner join to filter keys and enrich the output with parent columns like business keys.

Parameters
- key_column: is the business or hash key column shared across all satellites. This is what ties the satellites together.
- parent_model: is an optional parent model name (e.g., a hub or link). When specified, the output is inner-joined to this model, filtering to only keys that exist in the parent and adding any extra columns from it (excluding rsrc and ldts).
- source_models: is a dictionary where each key is a satellite model name and each value is a configuration object. The configuration object supports the following properties:
  - hash_diff_input: is a list of column names from that satellite to include in the output and in the hash diff calculation. Always include cdc_operation here.
  - column_prefix: is an optional string prepended to all column names from this satellite to avoid name collisions (e.g., "personal" turns first_name into personal_first_name).
  - keep_values_for_cdc_operation_delete: is an optional list of columns that should retain their values even when the cdc_operation is a delete. By default, all descriptive columns are set to NULL on deletes.
  - multi_active: is an optional boolean (default false). Set to true if the satellite can have multiple active rows per key at the same point in time.
  - ledts: Optional. is the name of the load-end-date column in your satellites (e.g., "ledts"). If this column exists in a satellite, a BETWEEN join is used. If it does not exist, an ASOF JOIN is used instead.
- incremental_delta_check is a boolean. When true, the macro compares the hash diff of the first new row per key against the latest existing row in the target table. If they match, the row is skipped to avoid redundant inserts.
- custom_rsrc: is a custom record source value for the output.

Key Behaviors
- Delete handling: When cdc_operation is D or Delete, all descriptive columns are set to NULL — unless a column is explicitly listed in keep_values_for_cdc_operation_delete. The cdc_operation column itself is always kept as-is. Internally, the macro normalises both D and Delete to a single value D for consistent hash diff computation, ensuring that a transition from delete back to an active record is always detected as a change.
- Join strategy: Satellites are automatically sorted by row count (smallest first) before joining. 
  - If a satellite has a ledts column, a LEFT JOIN with BETWEEN is used. 
  - If the satellite is marked as multi-active, a LEFT JOIN with a correlated subquery is used to return all active rows. 
  - Otherwise, an ASOF JOIN is used for optimal performance.
- Deduplication: After joining, a QUALIFY clause with LAG removes consecutive rows where the hash diff has not changed. This means the output only contains rows where at least one tracked column actually changed.

Example
Below is an example model that merges two satellites — one for personal customer data and one for financial customer data.

-----------------------------------------------------------------------------
{{ config(
    materialized='incremental'
) }}

{{ delta_merge_sat(
    key_column='customer_hk',
    parent_model='hub_customer'
    source_models={
        'sat_customer_personal': {
            'hash_diff_input': ['first_name', 'last_name', 'address', 'cdc_operation'],
            'column_prefix': 'personal',
            'keep_values_for_cdc_operation_delete': []
        },
        'sat_customer_financial': {
            'hash_diff_input': ['income', 'credit_score', 'cdc_operation'],
            'column_prefix': 'financial',
            'keep_values_for_cdc_operation_delete': ['credit_score']
        }
    },
    ledts='ledts',
    custom_rsrc='SAT_MERGE',
    incremental_delta_check=true    
) }}
-----------------------------------------------------------------------------

In the example above, sat_customer_personal contributes four columns prefixed with personal_ (personal_first_name, personal_last_name, personal_address, personal_cdc_operation). On deletes, all three descriptive columns become NULL (except the CDC_OPERATION itself).
sat_customer_financial contributes three columns prefixed with financial_ (financial_income, financial_credit_score, financial_cdc_operation). On deletes, credit_score retains its value because it is listed in keep_values_for_cdc_operation_delete, while income becomes NULL.
The output is filtered to only keys that exist in hub_customer, and any extra columns from the hub (beyond the key and metadata) are included in the result.

Output Columns
The output contains the key column (customer_hk), the timestamp column (ldts), a dms_hash_diff column used for incremental delta checking, and all columns listed in hash_diff_input for each source model — prefixed with the respective column_prefix. If a parent_model is specified, any additional columns from the parent (excluding rsrc and ldts) are also included.

#}

{%- macro delta_merge_sat(
    key_column,
    source_models,
    ledts,
    custom_rsrc,
    incremental_delta_check,
    parent_model
) -%}

{# First some default variable settings as we know from the standard PIT macro. #}

    {%- set hash = var("datavault4dbt.hash", "MD5") -%}
    {%- set hash_dtype = var("datavault4dbt.hash_datatype", "STRING") -%}
    {%- set hash_default_values = fromjson(
        datavault4dbt.hash_default_values(
            hash_function=hash, hash_datatype=hash_dtype
        )
    ) -%}
    {%- set unknown_key = hash_default_values["unknown_key"] -%}

    {%- set rsrc = var("datavault4dbt.rsrc_alias", "rsrc") -%}

    {%- set beginning_of_all_times = datavault4dbt.beginning_of_all_times() -%}
    {%- set end_of_all_times = datavault4dbt.end_of_all_times() -%}
    {%- set timestamp_format = datavault4dbt.timestamp_format() -%}

    {# Get parent model reference and columns if specified #}
    {%- set parent_model_ref = ref(parent_model) if parent_model else none -%}
    {%- set parent_columns = [] -%}
    {%- if parent_model %}
        {%- set all_parent_columns = dbt_utils.get_filtered_columns_in_relation(
            from=parent_model_ref, 
            except=["RSRC", "LDTS", "rsrc", "ldts"]
        ) -%}
        {%- for col in all_parent_columns %}
            {%- if col | lower != key_column | lower %}
                {%- do parent_columns.append(col) %}
            {%- endif %}
        {%- endfor %}
    {%- endif %}

    {# Order source_models by row count (smallest first) for optimized joins #}
    {%- set models_with_counts = [] -%}
    {%- for model, obj in source_models.items() -%}
        {%- set row_count = get_row_count(ref(model)) -%}
        {%- do models_with_counts.append({
            'model': model, 
            'obj': obj, 
            'row_count': row_count
        }) -%}
    {%- endfor -%}

    {# Sort models by row_count ascending #}
    {%- set sorted_models = models_with_counts | sort(attribute='row_count') -%}

    {# Rebuild source_models as ordered dictionary #}
    {%- set ordered_source_models = {} -%}
    {%- for item in sorted_models -%}
        {%- do ordered_source_models.update({item['model']: item['obj']}) -%}
    {%- endfor -%}

    {# Following we create a list of the input columns for the HashDiff. In case something is defined in the
    hash_diff_input variable for a Satellite, these are used. If not, the LDTS will be used to detect a delta
    for the whole Satellite. #}

    {%- set hash_diff_input_list = [] %}

    {%- for model, obj in ordered_source_models.items() -%}
        {# We expect a CDC_OPERATION column in all sources. We normalise to 'D' for both the
           standard single-character 'D' and the non-standard 'Delete' string that some source
           systems emit, so that a Delete→C transition with unchanged payload is still treated
           as a meaningful change (D→U) and the re-creation row is not deduped away. #}
        {%- do hash_diff_input_list.append('iff(lower(' + model + '.cdc_operation) in (\'d\', \'delete\'), \'D\', \'U\')') -%}
        {%- if obj %}
            {%- for col in obj.hash_diff_input -%} {%- do hash_diff_input_list.append(model + '.' + col | lower()) -%} {% endfor %}
        {%- endif -%}
    {%- endfor %}


{# Generate SQL column references with user-provided column_prefix for each source model #}
    {%- set merged_column_list = [] -%}

    {%- for source_model, model_details in ordered_source_models.items() -%}
        {%- set prefix = model_details.column_prefix | default('', true) -%}
        {%- set col_alias_prefix = prefix ~ "_" if prefix else "" -%}
        {%- set keep_on_delete = model_details.keep_values_for_cdc_operation_delete | default([], true) -%}
        {%- set keep_on_delete_lower = keep_on_delete | map('lower') | list -%}
        {%- for column_name in model_details.hash_diff_input -%}
            {# In case CDC_OPERATION is 'D', use NULL for descriptive columns (except cdc_operation itself and columns listed in keep_values_for_cdc_operation_delete) #}
            {%- if column_name | lower == 'cdc_operation' -%}
                {%- set final_reference = source_model ~ "." ~ column_name ~ " AS " ~ col_alias_prefix ~ column_name -%}
            {%- elif column_name | lower in keep_on_delete_lower -%}
                {%- set final_reference = source_model ~ "." ~ column_name ~ " AS " ~ col_alias_prefix ~ column_name -%}
            {%- else -%}
                {%- set final_reference = "iff(lower(" ~ source_model ~ ".CDC_OPERATION) not in ('d', 'delete'), " ~ source_model ~ "." ~ column_name ~ ", NULL) AS " ~ col_alias_prefix ~ column_name -%}
            {%- endif -%}
            {%- do merged_column_list.append(final_reference) -%}
        {%- endfor -%}
    {%- endfor -%}

    with
        {#- Get the maximum snapshot for incremental logic. In case it is a full-load, we start with the parameter "snapshot_start_date".
            We also subtract one day from that date to be able to use just a ">" in the incremental logic later. #}
        max_ldts as (
            select
            {%- if is_incremental() %}
                max(ldts) as max_ldts
            from {{ this }}
            where ldts != '{{ end_of_all_times }}'::TIMESTAMP_NTZ
            {%- else %}
                '{{ beginning_of_all_times }}'::TIMESTAMP_NTZ as max_ldts
            {%- endif %}
        ),

        {# Get the parent model with distinct key_column values #}
        {%- if parent_model %}
        parent_keys as (
            select
                {{ key_column }}
                {%- for col in parent_columns %}
                , {{ col }}
                {%- endfor %}
            from {{ parent_model_ref }}
        ),
        {%- endif %}

        all_ldts as (
            {%- for model in ordered_source_models %}
                {%- set model_obj = ordered_source_models[model] -%}
                select 
                    {{ model }}.{{ key_column }},
                    ldts as ldts,
                    {%- for inner_model in ordered_source_models %}
                        {%- if model == inner_model -%}
                            ldts as ldts_{{ inner_model -}}
                        {%- else -%}
                            null as ldts_{{ inner_model -}}
                        {%- endif -%}
                        {%- if not loop.last -%},{%- endif -%}
                    {%- endfor -%}
                 {{- " " }} from {{ ref(model) | lower() }}
                {%- if is_incremental() %} 
                where ldts > (select max_ldts from max_ldts)
                    and ldts != '{{ end_of_all_times }}'::TIMESTAMP_NTZ
                {%- endif %}
                {%- if not loop.last %} union all {% endif %}
            {%- endfor %}
        ),        
        {#- Get a distinct list of key_column + ldts combinations. The reason why we do this is, 
            that we do not want to create a snapshot for every day (or whatever is derived from the snapshot_master table), 
            but only for the deltas from one snapshot to the next per key on a daily base. That means, that we get the snapshots,
            which we want to create per key, not from the snapshot_master table, but from the Satellites directly. 
            This reduces the amount of records already from the very beginning.
            When this is done, we apply the standard PIT logic and searching for the most recent delta per snapshot. #}
        distinct_hk_ldts_list as (
            select 
                {{ key_column }}, 
                ldts
                {%- for model in ordered_source_models %}
                    ,max(ldts_{{ model }}) as ldts_{{ model }}
                {%- endfor %}
            from all_ldts
            group by 
                {{ key_column }}, 
                ldts
        ),        
        inherit_values as (
            select 
                {{ key_column }}, 
                ldts
                {# Not necessary to act like a PIT here and store the HK+LDTS columns for each Satellite 
                {%- for model in ordered_source_models %}
                    last_value(ldts_{{ model }} ignore nulls) over (partition by {{ key_column }} order by ldts rows between unbounded preceding and current row) as ldts_{{ model }}{{ ',' if not loop.last else '' }}
                {%- endfor %}
                #}
            from distinct_hk_ldts_list
        ),
        {# Get the latest LDTS per key_column. In addition, the HashDiff is added as well to perform the
        delta check with the new data later. #}
        {%- if is_incremental() and hash_diff_input_list|length > 0 and incremental_delta_check %}
        latest_entries_in_dms as (
            select
                {{ key_column }},
                dms_hash_diff
            from {{ this }}
            qualify row_number() over(partition by {{ key_column|lower }} order by ldts desc) = 1
        ),
        {%- endif %}

        {# This is the main part of the macro where we get the new LDTS based on incremental logic.
        We use the distinct key_column+LDTS list from the cte above and search with the standard PIT logic
        for the most recent delta in the Satellites.
        Additionally, we perform a deduplication when we perform multiple snapshots at the same time 
        when there was no delta between two snapshots. #}
        delta_records as (

            select

                base.{{ key_column }},
                base.ldts
                {# Not necessary to act like a PIT here and store the HK+LDTS columns for each Satellite #}
                {%- if hash_diff_input_list|length > 0 %}
                , {{
                    datavault4dbt.hash(
                        columns=hash_diff_input_list, alias="dms_hash_diff"
                    )
                }}
                , row_number() over(partition by base.{{ key_column }} order by base.ldts) as rn
                , {{ merged_column_list | join(',\n') }}
                {%- endif %}
            from inherit_values base
            {# Join satellites in order of row count (smallest first) #}
            {% for model, obj in ordered_source_models.items() %}
                {%- set sat_columns = datavault4dbt.source_columns(
                    ref(model)
                ) %}
                {%- set is_multi_active = obj.multi_active | default(false) %}
                {%- if ledts | string | lower in sat_columns | map("lower") %}
                    {# Has LEDTS: LEFT JOIN with BETWEEN (already returns all multi-active rows) #}
                    left join {{ ref(model) }}
                        on {{ model }}.{{ key_column }} = base.{{ key_column }}
                        and base.ldts
                        between {{ model }}.ldts and {{ model }}.ledts
                {%- elif is_multi_active %}
                    {# Multi-active satellite without LEDTS: use LEFT JOIN with correlated
                       subquery to return ALL rows at the latest matching ldts.
                       ASOF JOIN would return only one row, dropping other multi-active records. #}
                    left join {{ ref(model) }}
                        on {{ model }}.{{ key_column }} = base.{{ key_column }}
                        and {{ model }}.ldts = (
                            select max(_ma_sub.ldts)
                            from {{ ref(model) }} _ma_sub
                            where _ma_sub.{{ key_column }} = base.{{ key_column }}
                            and _ma_sub.ldts <= base.ldts
                        )
                {%- else %}
                    {# Standard satellite without LEDTS: ASOF JOIN (returns exactly one row) #}
                    asof join {{ ref(model) }}
                        match_condition (base.ldts >= {{ model }}.ldts)
                        on base.{{ key_column }} = {{ model }}.{{ key_column }}
                {% endif %}
                    
            {% endfor %}
            {%- if hash_diff_input_list|length > 0 %}
            qualify
                case
                    when dms_hash_diff = lag(dms_hash_diff) over(partition by base.{{ key_column|lower }} order by base.ldts) then false
                    else true
                end
            {% endif %}
        )

        {# The main Select gets its data from the main cte before and checks whether there is a delta between the highest
        LDTS from the delta_merge and lowest LDTS from the new data (of course also per key_column). #}
        select 
            {%- if parent_model %}
            parent_keys.{{ key_column }},
            {%- for col in parent_columns %}
            parent_keys.{{ col }},
            {%- endfor %}
            delta_records.ldts
            {%- else %}
            delta_records.{{ key_column }},
            delta_records.ldts
            {%- endif %}
            {%- if hash_diff_input_list|length > 0 and incremental_delta_check %}
            , delta_records.dms_hash_diff
            {%- endif %}
            {%- if hash_diff_input_list|length > 0 %}
                {%- for source_model, model_details in ordered_source_models.items() %}
                    {%- set prefix = model_details.column_prefix | default('', true) %}
                    {%- set col_alias_prefix = prefix ~ "_" if prefix else "" %}
                    {%- for column_name in model_details.hash_diff_input %}
            , delta_records.{{ col_alias_prefix }}{{ column_name }}
                    {%- endfor %}
                {%- endfor %}
            {%- endif %}
        from delta_records
        {%- if parent_model %}
        inner join parent_keys 
            on parent_keys.{{ key_column }} = delta_records.{{ key_column }}
        {%- endif %}
        {%- if is_incremental() and hash_diff_input_list|length > 0 and incremental_delta_check %}
        where not exists (
            select 1
            from latest_entries_in_dms
            where delta_records.{{ key_column }} = latest_entries_in_dms.{{ key_column }}
                and delta_records.dms_hash_diff = latest_entries_in_dms.dms_hash_diff
                and delta_records.rn = 1
        )
        {%- endif %}

{%- endmacro -%}