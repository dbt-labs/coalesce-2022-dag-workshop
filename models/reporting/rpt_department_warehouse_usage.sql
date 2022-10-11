{#
    Exercise: Creating a department warehouse usage report.
    For this exercise, we want a model that uses the `statement`
    block to generate a pivot table, where each column is a
    department, and each row is the total execution time
    consumed by each department.

    Statement Block: https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks
#}

{{
    config(
        enabled=False
    )
}}


{#
    TODO: Use a statement block to obtain a unique list of departments.
    the output of the associated load_result should go into a variable named
    `departments`.
#}
{%- call statement('departments', fetch_result=True) -%}

    {# this pulls the unique departments from the fct_materializations table #}
    select distinct owner_department from {{ ref('fct_materializations') }}

{%- endcall %}

{% set departments = load_result('departments').table.columns[0].values() %}

select
    date_part('month', executed_at) as materialization_month,

    {# Loop over departments array from above, and sum execution time based on whether the record matches the department#}
    {%- for department in departments -%}
        sum(
            case
                when owner_department = '{{department}}'
                    then execution_duration
            end
        ) as "{{department | lower |replace(' ', '_')}}_duration"
        {%- if not loop.last -%},{% endif %}
    {% endfor %}

from {{ ref('fct_materializations') }}
group by 1