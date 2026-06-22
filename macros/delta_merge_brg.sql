{#- 
The delta_merge_brg macro merges a main SCD2-driven table with one or more related tables into a single unified timeline per business key. 
It acts as a bridge table builder that tracks changes across a main table and all its foreign-key relationships.

If you have a main table tracking loan accounts with foreign keys pointing to interest rate tables, collateral tables, and customer tables — all changing independently — this macro 
produces a single table where every row has all columns filled in with the values that were valid at that point in time, across all related tables.

How It Works
The macro performs these steps in order:
- Collects all change timestamps from the main table for the business key and all tracked columns (primary key, foreign keys, and any explicitly included columns). This becomes the main_changes CTE.
- Processes each related table in dependency order. For each relation, it collects all changes from that table and creates initial base values (a row at the beginning of all times) so that inheritance always has a starting point.
- The relations can relate to the main table or to previously processed relations, enabling chaining (e.g., if table C joins against table B which has already joined against table A).
- Joins each relation against its parent CTE. By default, relations join against main_changes, but they can also join against a previously processed relation using the join_to_alias parameter. This enables chained joins where table C joins table B which already joined table A.
- Merges timelines using GREATEST/LEAST. When a related table changes, the macro uses greatest_ignore_nulls on ldts and least_ignore_nulls on ledts to produce the correct validity period for the combined row. This avoids multiple window functions.
- Handles deletes. When a related table's cdc_operation is D or Delete, all included columns from that relation are set to NULL.
- Removes non-contributing rows. Rows where the computed ldts equals the computed ledts are filtered out, as they represent zero-length intervals that add no value to the history.
- Supports incremental loading. On incremental runs, only changes since the last loaded ldts in the target are processed. Active rows at that point in time are included to capture changes from relations, with a final filter on ldts applied at the end.
- Optimises join order. Relations within the same dependency group are sorted by row count (smallest first) to minimise memory usage during joins.

Parameters
- source_model: is the name of the main table (e.g., a satellite or staging table). The macro wraps it in ref() automatically if it is a string.
- key_column: is the primary key column in the main table. This is the column that is tracked for changes and ties everything together.
- include: is a list of columns to include from the main table. Foreign key columns must be listed here if they are needed to join related tables. Use "*" to include all columns (excluding metadata columns like LDTS, LEDTS, CDC_OPERATION, etc.).
- prefix: is an optional string prepended to all column names from the main table to avoid name collisions.
- filter: is an optional filter expression applied to the main table (e.g., to filter on a specific type or status).
- relations: is a list of dictionaries, where each dictionary defines a related table to join. Each dictionary supports the following properties:
  - relation: is the name of the related table. The macro wraps it in ref() automatically.
  - from_column: is the foreign key column in the main table (or parent alias) that points to this relation.
  - to_column: is the column in the related table that is pointed to by the foreign key.
  - include: is a list of columns to include from this relation. Use "*" to include all non-metadata columns.
  - prefix: is a string prepended to all column names from this relation.
  - alias: is an optional alias for this relation. If not specified, it defaults to the table name combined with the from_column.
  - filter: is an optional filter expression applied to this relation.
  - join_to_alias: is the alias of the table this relation should join against. Default is "main". Use this to chain joins so that table C joins against table B, which has already joined against table A.

Key Behaviors
	- Delete handling: When a related table's cdc_operation is D or Delete, all included columns from that relation are set to NULL. The main table's columns remain unaffected.
	- Join strategy: All relations use a LEFT JOIN with a BETWEEN condition on ldts/ledts to find which rows from the related table are active at the time of the main table's row. Initial base values are created for each relation at the beginning of all times to ensure inheritance always has a starting point.
	- Chained joins: Relations can join against previously processed relations using the join_to_alias parameter. The macro resolves dependencies automatically — relations that depend on main are processed first, then relations that depend on those, and so on. Circular or unresolved dependencies raise a compiler error.
	- Join order optimisation: Within each dependency group, relations are sorted by row count (smallest first) to reduce the size of intermediate results.
  - Timeline merging: The macro uses greatest_ignore_nulls on ldts and least_ignore_nulls on ledts to compute the correct validity period when combining rows from different tables. Rows where the resulting ldts equals the resulting ledts (zero-length intervals) are removed.
  - Incremental loading: On incremental runs, the macro includes all rows that are active at the time of the last loaded ldts in the target. This ensures that changes from related tables are captured even if the main table has not changed. A final filter removes rows with ldts less than or equal to the last loaded timestamp.

Example
This macro is not called directly in models. Instead, you call the wrapper macro delta_merge_brg. Below is an example model that merges a loan account satellite with related interest rate and collateral tables.

------------------------------------------------------------------------------
{{ config(
    materialized='incremental'
) }}

{{ delta_merge_brg(
    source_model='sat_loan_account',
    key_column='loan_hk',
    include=['loan_hk', 'interest_rate_fk', 'collateral_fk', 'loan_amount'],
    prefix='loan',
    relations=[
        {
            'relation': 'sat_interest_rate',
            'from_column': 'interest_rate_fk',
            'to_column': 'interest_rate_hk',
            'include': ['rate_percentage', 'rate_type'],
            'prefix': 'interest',
            'alias': 'interest'
        },
        {
            'relation': 'sat_collateral',
            'from_column': 'collateral_fk',
            'to_column': 'collateral_hk',
            'include': ['collateral_value', 'collateral_type'],
            'prefix': 'collateral',
            'alias': 'collateral'
        }
    ]
) }}
------------------------------------------------------------------------------

In this example, sat_loan_account is the main table with two foreign keys pointing to sat_interest_rate and sat_collateral. The output contains all columns from all three tables, prefixed to avoid collisions, with a unified timeline that reflects every change across all three tables.
To chain joins (e.g., if sat_collateral has its own foreign key to a valuation table), add join_to_alias: 'collateral' to the valuation relation so it joins against the already-processed collateral CTE rather than directly against main.

Output Columns
The output contains the key column (loan_hk), the timestamp column (ldts), and all columns listed in include for the main table and each relation — each prefixed with their respective prefix. The ledts column is excluded from the final output.
 -#}
{%- macro delta_merge_brg(source_model, include, prefix, relations, key_column, filter=none) %}

{%- set beginning_of_all_times = datavault4dbt.beginning_of_all_times() -%}

{#- Wrap source_model in ref() if it's a string #}
{%- set source_model_ref = ref(source_model) if source_model is string else source_model -%}

{%- set main_relation = {"relation": source_model_ref, "from_column": key_column, "to_column": key_column, "include": include, "prefix": prefix, "alias": "main", "filter": filter, "is_ref_applied": true} %}
{%- do relations.insert(0, main_relation) -%}

{#- Create a dictionary to track which CTE each alias produces #}
{%- set alias_to_cte = {"main": "main_changes"} %}

{%- set new_relations = [] %}
{%- for tbl_readonly in relations %}
    {%- set tbl = tbl_readonly.copy() %}

    {#- Add support for nesting - default to "main" if not specified #}
    {%- if tbl.join_to_alias is undefined %}
        {%- set _ = tbl.update({'join_to_alias': 'main'}) %}
    {%- endif %}

    {#- Apply ref() to relation if not already applied and not main #}
    {%- if tbl.is_ref_applied is undefined or not tbl.is_ref_applied %}
        {%- if tbl.relation is string %}
            {%- set _ = tbl.update({'relation': ref(tbl.relation)}) %}
        {%- endif %}
        {%- set _ = tbl.update({'is_ref_applied': true}) %}
    {%- endif %}

    {%- if tbl.alias is undefined %} 
        {%- set _ = tbl.update({'alias': tbl.relation.identifier ~ "_" ~ tbl.from_column}) %}
    {%- endif %}

    {#- Get all columns for all relations if * is used #}
    {%- if tbl.include == "*" or tbl.include == ["*"] %}
        {%- set _ = tbl.update({'include': dbt_utils.get_filtered_columns_in_relation(from=tbl.relation, except=["LDTS","LEDTS","LOADED","CHKSUM","HASH_VALUES","MD5_VALUES", "CDC_OPERATION","MAX_LOAD_DATETIME","MIN_LOAD_DATETIME",key_column])}) -%}
    {%- endif %}

    {#- Count rows in relation. Largest is taken last. #}
    {%- set _ = tbl.update({'row_count': get_row_count(tbl.relation, tbl.filter if tbl.filter else none) if not tbl.alias == "main" else 0 }) %}

    {%- do new_relations.append(tbl) %}
{%- endfor %}

{%- set relations = new_relations %}

{#- Build dependency order: relations that depend on "main" first, then those that depend on already processed relations #}
{#- Within each dependency group, order by row_count (smallest first) for memory optimization #}
{%- set ordered_relations = [] %}
{%- set processed_aliases = ["main"] %}
{%- set remaining_relations = [] %}

{#- First pass: collect all relations that depend on "main" #}
{%- set main_dependents = [] %}
{%- for tbl in relations if not tbl.alias == "main" %}
    {%- if tbl.join_to_alias == "main" %}
        {%- do main_dependents.append(tbl) %}
    {%- else %}
        {%- do remaining_relations.append(tbl) %}
    {%- endif %}
{%- endfor %}

{#- Sort main_dependents by row_count (smallest first) and add to ordered_relations #}
{%- set sorted_main_dependents = main_dependents | sort(attribute='row_count') %}
{%- for tbl in sorted_main_dependents %}
    {%- do ordered_relations.append(tbl) %}
    {%- do processed_aliases.append(tbl.alias) %}
{%- endfor %}

{#- Subsequent passes: add relations whose dependencies have been processed, sorted by row_count within each group #}
{#- Use namespace so that reassignment inside the for loop persists to the outer scope (Jinja2 scoping limitation) #}
{%- set ns = namespace(remaining_relations=remaining_relations) %}
{%- set max_iterations = ns.remaining_relations | length + 1 %}
{%- for _ in range(max_iterations) %}
    {#- Collect all relations that can be processed in this iteration #}
    {%- set current_batch = [] %}
    {%- set still_remaining = [] %}
    {%- for tbl in ns.remaining_relations %}
        {%- if tbl.join_to_alias in processed_aliases %}
            {%- do current_batch.append(tbl) %}
        {%- else %}
            {%- do still_remaining.append(tbl) %}
        {%- endif %}
    {%- endfor %}
    
    {#- Sort current batch by row_count (smallest first) and add to ordered_relations #}
    {%- set sorted_batch = current_batch | sort(attribute='row_count') %}
    {%- for tbl in sorted_batch %}
        {%- do ordered_relations.append(tbl) %}
        {%- do processed_aliases.append(tbl.alias) %}
    {%- endfor %}
    
    {%- set ns.remaining_relations = still_remaining %}
    {%- if ns.remaining_relations | length == 0 %}
        {%- break %}
    {%- endif %}
{%- endfor %}

{#- Check for unresolved dependencies #}
{%- if ns.remaining_relations | length > 0 %}
    {%- set unresolved_aliases = [] %}
    {%- for tbl in ns.remaining_relations %}
        {%- do unresolved_aliases.append(tbl.alias ~ " (depends on: " ~ tbl.join_to_alias ~ ")") %}
    {%- endfor %}
    {% do exceptions.raise_compiler_error(this.identifier ~ ": Unresolved dependencies in 'relations'. The following relations have dependencies that cannot be resolved: " ~ unresolved_aliases | join(", ")) %}
{%- endif %}


    with
    {#- This is created from main and gets all changes on pk, fk and include columns #}
    main_changes as (
        {#- Init with pk #}
    {%- set track_columns = [key_column | lower] %}

    {%- for tbl in relations -%}
        {%- if tbl.alias == "main" %}
            {#- Track the include columns we're asked to track changes on. Might as well do it from the start. #}
            {%- for col in tbl.include %}
                {%- if col|lower not in track_columns %}
                    {%- do track_columns.append(col | lower) %}
                {%- endif %}
            {%- endfor %}        
        {%- else %}        
            {#- Track all fk - but only if join_to_alias is "main" #}
            {%- if tbl.join_to_alias == "main" and tbl.from_column|lower not in track_columns %}
                {%- do track_columns.append(tbl.from_column|lower) %}
            {%- endif %}
        {%- endif %}
    {%- endfor %}
    {{- get_changes(relation=source_model_ref, key_column_name=key_column, include=track_columns, calculate_expire=true, filter=filter) }}
    {%- if is_incremental() %}
        {#- We must include everything that is active at this time to capture changes from relations. Extra filtering on ldts at the end! #}
        where ldts >= coalesce((select max(ldts) from {{ this }}), '1900-01-01')
    {%- endif %}
    )


{%- set previous_changes = {} -%}
{%- do previous_changes.update({'relation': "main_changes"}) %}

{#- *************** Iterate once per relation that is not "main" - now in dependency order #}
{%- for tbl in ordered_relations -%}

    {#- Determine which CTE to join against based on join_to_alias #}
    {%- set join_against_cte = alias_to_cte[tbl.join_to_alias] %}

    {#- Must create relation_changes for this table to reduce the number of rows that double up the left table / main (It's possible to reuse this if you hash include-name and filter) #}
    ,relation_changes_ {{- tbl.alias }} as (
            {{- get_changes(relation=tbl.relation, key_column_name=tbl.to_column, include=tbl.include, filter=tbl.filter, calculate_expire=true) -}}
            {%- if is_incremental() %}
                {#- We must include everything that is active at this time to capture changes from relations. Extra filtering on ldts at the end! #}
                where ledts >= coalesce((select max(ldts) from {{ this }}), '1900-01-01')
            {%- endif %}            
    )
    {#- Want to create a set of initial values for all keys in relation_changes #}
    ,initial_base_values_{{- tbl.alias }} as (
        select '{{ beginning_of_all_times }}'::timestamp_ntz(9) as ldts, min(ldts) as ledts, {{ tbl.to_column }}
        from relation_changes_ {{- tbl.alias }} src
        group by {{ tbl.to_column }}
    )
    ,relation_changes_and_initial_values_{{- tbl.alias }} as (
        select initial.{{ tbl.to_column }}, initial.ldts, initial.ledts, empty_values.* exclude({{ tbl.to_column }}, ldts, ledts)
        from initial_base_values_{{- tbl.alias }} initial
        left outer join (select * from relation_changes_ {{- tbl.alias }} limit 0) as empty_values on 1=0
        union all
        select relation_changes.{{ tbl.to_column }}, relation_changes.ldts, relation_changes.ledts, relation_changes.* exclude({{ tbl.to_column }}, ldts, ledts)
        from relation_changes_ {{- tbl.alias }} as relation_changes
    )
        {#- 
            For each change in foreign table, data is fetched from main so that we get all changes.
            Here the changes in main are doubled up as it joins on common key + between and not main's primary key 
        #}
    ,added_changes_{{- tbl.alias }} as (
        {#- All changes from foreign that hit rows in main. It joins on fk so that pk is doubled up massively - on purpose so that all rows from main get changes that have the same pk as them! #}
        select main.*
        {#- By using greatest/least below we hopefully avoid using multiple window functions! #}
        {#- We use the largest ldts across main and foreign for new ldts. Main's ldts is kept on the row from foreign that happens BEFORE main's row. If left join doesn't get result we just use main. #}
        replace(greatest_ignore_nulls(main.ldts, foreign.ldts) as ldts,
        {#- We use the smallest ledts as expire. If left join doesn't get result we just use main. #}
        least_ignore_nulls(main.ledts, foreign.ledts) as ledts)

        {#- This can be replaced with all fields we need directly! #}
        {#- , foreign.load_datetime as {{ "load_datetime_" ~ tbl.alias }} #}
        {#- Get all columns from foreign that are not pk or fk #}
        {%- for col in tbl.include  %}
            ,iff(lower(foreign.cdc_operation) not in ('d', 'delete'), foreign.{{ col }}, null) as {{ tbl.prefix ~ col }}
        {%- endfor %}

        from {{ join_against_cte }} main
        left join {{ "relation_changes_and_initial_values_" ~ tbl.alias }} as foreign 
            on main.{{ tbl.from_column }} = foreign.{{ tbl.to_column }} 
                {#- We need all rows from foreign that are active at the time of main's row. (I.e. a row where expire has not expired.) in addition to rows that happen before ledts in main! #}
                and foreign.ledts > main.ldts and foreign.ldts < main.ledts
        {#- Remove rows that don't contribute anything to the history #}
        where greatest_ignore_nulls(main.ldts, foreign.ldts) <> least_ignore_nulls(main.ledts, foreign.ledts)
        )

    {#- Update the alias_to_cte mapping and previous_changes #}
    {%- do alias_to_cte.update({tbl.alias: "added_changes_" ~ tbl.alias}) %}
    {%- do alias_to_cte.update({tbl.join_to_alias: "added_changes_" ~ tbl.alias}) %}
    {%- do previous_changes.update({'relation': "added_changes_" ~ tbl.alias }) %}

{%- endfor %}

select * exclude(ledts)
from {{ previous_changes['relation'] }}
{%- if is_incremental() %}
    {#- We must include everything that is active at this time to capture changes from relations. Extra filtering on ldts at the end! #}
    where ldts > coalesce((select max(ldts) from {{ this }}), '1900-01-01')
{%- endif %}

{%- endmacro %}