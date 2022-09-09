{% macro store_materialization_results(results, table_name) %}

  {%- set central_tbl -%}
    {{ target.schema }}.{{ table_name }}
  {%- endset -%}

  {%- set materialization_results = [] -%}
  {%- for result in results if result.node.resource_type == 'model' -%}
    {%- do materialization_results.append(result) -%}
  {%- endfor -%}

  {# if no models were materialized, do nothing! #}
  {% if materialization_results | length == 0 -%}
    {{ return('select 1') }}
  {%- endif -%}

  {{ log("Centralizing materialization data in " + central_tbl, info = true) if execute }}

  {#
		Check if the target table exists. If it does, then insert into it. Otherwise, create it.
	#}
  {% set central_table_query %} {{ dbt_utils.get_tables_by_pattern_sql(target.schema | upper,  table_name ) }} {% endset %}

  {% if execute %}
    {% set central_table_exists = run_query(central_table_query) %}
  {% endif %}

  {% if central_table_exists%}
    insert into {{ central_tbl }} (
  {% else %}
    create table {{ central_tbl }} as (
  {% endif %}

	{# For each result in the run result set, process and store the result. #}
  {% for result in materialization_results %}

    {# Remap the timing list into a dictionary of values #}
    {% set timing = {} %}
    {% for timing_record in result.timing%}
      {% do timing.update({ timing_record['name']: {
          'started_at': timing_record['started_at'],
          'completed_at': timing_record['completed_at']
        } }) %}
    {% endfor %}

		{# Generate a row for each result, which maps to one row per model. #}
    select
      {{ dbt_utils.surrogate_key( ["'" ~ invocation_id ~ "'" , "'" ~ result.node.unique_id ~ "'" ] ) }} as materialization_id,
      '{{ result.node.unique_id }}'::text as node_unique_id,
      '{{ invocation_id }}'::text as invocation_id,
      '{{ result.node.name }}'::text as model,
      '{{ result.node.schema }}'::text as "schema",
      '{{ result.node.database }}'::text as "database",
      '{{ result.node.config.materialized }}'::text as materialization,
      '{{ result.status }}'::text as status,
      '{{ timing["compile"]["started_at"] }}'::timestamptz as compile_started_at,
      '{{ timing["compile"]["completed_at"] }}'::timestamptz as compile_completed_at,
      '{{ timing["execute"]["started_at"] }}'::timestamptz as execution_started_at,
      '{{ timing["execute"]["completed_at"] }}'::timestamptz as execution_ended_at,
      '{{ result.execution_time }}'::float as execution_time_seconds,
      '{{ result.node.original_file_path }}'::text as model_file_path,
      '{{ result.node.checksum.checksum }}'::text as checksum,
      current_timestamp as recorded_at

    {{ "union all" if not loop.last }}

  {% endfor %}

  );
{% endmacro %}