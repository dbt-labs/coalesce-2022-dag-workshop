{{
    config(
        enabled=false
    )
}}


with

materializations as (
    select * from {{ source('dbt', 'materializations') }}
),

final as (
    select
        materialization_id,
        node_unique_id,
        invocation_id,
        model,
        status,
        meta:maturity::text as maturity,
        meta:owner:email::text as owner_email,
        meta:owner:department::text as owner_department,
        execution_started_at as executed_at,
        execution_time_seconds as execution_duration,
        recorded_at
    from materializations
)

select * from final