{{
    config(
        enabled=True
    )
}}


with

final as (
    select * from {{ ref('stg_dbt__materializations') }}
)

select * from final
