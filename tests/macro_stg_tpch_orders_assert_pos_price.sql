-- depends_on: {{ ref('stg_tpch__orders') }}

{{
    config(
        enabled=true,
        severity='error',
        tags = ['finance']
    )
}}


{{ test_all_values_gte_zero('stg_tpch__orders', 'total_price') }}