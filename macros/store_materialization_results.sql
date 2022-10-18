{#
    Exercise: Create a macro that stores model run results (materializations) after each
    run. For this exercise, we want to create a list of model materialization results, that
    can be stored the the data warehouse by crafting a custom table to store this data. In
    the TODOs below, there will be opportunities to identify model materialization results,
    determine if a new table is being created, or if new records are being inserted, and lastly
    to craft the specific select statement that will provide the desired information.

    Useful links:
    - Results Object: https://docs.getdbt.com/reference/dbt-classes#result-objects
    - Node Object: https://schemas.getdbt.com/dbt/manifest/v6/index.html#tab-pane_nodes_additionalProperties_oneOf_i2
    - `on-run-end`: https://schemas.getdbt.com/dbt/manifest/v6/index.html#tab-pane_nodes_additionalProperties_oneOf_i2
#}

{% macro store_materialization_results(results, table_name) %}

    {# Format a compelete table object string for use during data storage #}
    {%- set central_tbl -%}
    {{ target.schema }}.{{ table_name }}
    {%- endset -%}

    {# Create a list of materialization results for model resource types specifically. #}
    {%- set materialization_results = [] -%}

    {#
    TODO: Iterate though the results, check if the result pertains to a model by looking
    at the result Node's resource_type. If it is a model, then add it to the materialization_results list.
    #}

    {%- for result in results if result.node.resource_type == 'model' -%}
        {%- do materialization_results.append(result) -%}
    {%- endfor -%}

    {#
    Checking the `materialization_results` list if no models were materialized, return a no-op SQL query.
    This can be something like SELECT 1
    #}
    {% if materialization_results | length == 0 -%}
        {{ return('select 1') }}
    {%- endif -%}

    {# Similarly, if we're not in an execution context, we want to return now, too. #}
    {% if not execute %}
        {{ return('select 1') }}
    {% endif %}


    {# Check if the target table exists. If it does, then insert into it. Otherwise, create it. #}
    {% set central_table_query %} {{ dbt_utils.get_tables_by_pattern_sql(target.schema | upper,  table_name ) }} {% endset %}
    {% set central_table_exists = run_query(central_table_query) %}

    {#
        TODO: Add logic to set the query returned by this macro to either insert into {{ central_tbl }} or
        create table the table using the records processed below depending on the current existance of the table.
    #}
    {% if central_table_exists%}
        insert into {{ central_tbl }} (
    {% else %}
        create table {{ central_tbl }} as (
    {% endif %}

    {# For each result in the run result set, process and store the result. #}
    {% for result in materialization_results %}

        {# Check if this model references models with a low maturity.#}
        {{ ref_maturity_warning(current_model = result.node, warning_maturity_levels=['low']) }}

        {# Remap the timing list into a dictionary of values #}
        {% set timing = {} %}
        {% for timing_record in result.timing%}
          {% do timing.update({ timing_record['name']: {
              'started_at': timing_record['started_at'],
              'completed_at': timing_record['completed_at']
              } }) %}
        {% endfor %}

        {# Generate a row for each result, which maps to one row per model. #}
        {#
            TODO: Craft a select statement that will provide our deisred fields. This would include:
            a unique materialization_id, the result node's unique Id, the invocation_id, the model's name,
            the result status, the `meta` data from result node, the time the query started and stoped executing,
            the total execution time, and the current timestamp.

            These values are currently set to null, and should be replaced with the jinja values of interest.
        #}
        select
        {{ dbt_utils.surrogate_key( ["'" ~ invocation_id ~ "'" , "'" ~ result.node.unique_id ~ "'" ] ) }} as materialization_id,
        '{{ result.node.unique_id }}'::text as node_unique_id,
        '{{ invocation_id }}'::text as invocation_id,
        '{{ result.node.name }}'::text as model,
        '{{ result.status }}'::text as status,
        to_variant(parse_json('{{ tojson(result.node.config.meta) }}')) as meta,
        '{{ timing["execute"]["started_at"] }}'::timestamptz as execution_started_at,
        '{{ timing["execute"]["completed_at"] }}'::timestamptz as execution_completed_at,
        '{{ result.execution_time }}'::float as execution_time_seconds,
        current_timestamp as recorded_at

        {{ "union all" if not loop.last }}

    {% endfor %}

    );



{% endmacro %}