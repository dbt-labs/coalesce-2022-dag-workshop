
{#
    TODO: Use a statement block to obtain a unique list of departments.
    the output of the associated load_result should go into a variable named
    `departments`.
#}



{% set departments = load_result('departments').table.columns[0].values() %}

select
    date_part('month', executed_at) as materialization_month,

    {# Loop over departments array from above, and sum execution time based on whether the record matches the department#}
    {%- for department in departments -%}

        {#
            TODO: Implement the SQL logic required to only sum the
            durations for the selected department in this part of
            the loop.
        #}

    {% endfor %}

from {{ ref(