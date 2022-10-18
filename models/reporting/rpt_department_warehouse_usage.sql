{#
    Exercise: Creating a department warehouse usage report.
    For this exercise, we want a model that uses the `statement`
    block to generate a pivot table, where each column is a
    department, and each row is the total execution time
    consumed by each department.

    Statement Block: https://docs.getdbt.com/reference/dbt-jinja-functions/statement-blocks

#}

{#

In order to successfully run this model, first ensure you have a working store_materialization_results macro and then do a dbt run.
You can copy and paste a working solution from the _checkpoint_1 branch if you need to. 

Secondly, you will need to go into the following model files and enable them by deleting the config block and saving:

- models/staging/dbt_metadata/stg_dbt__materializations
- models/marts/analytics/fct_materializations

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



{% set departments = load_result('departments').table.columns[0].values() %}

select
    date_trunc('month', executed_at) as materialization_month,

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