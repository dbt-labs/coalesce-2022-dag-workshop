-- depends_on: {{ ref('stg_tpch__suppliers') }}

{{
    config(
        enabled=true,
        severity='warn',
        tags = ['finance']
    )
}}


{{ test_all_values_gte_zero('stg_tpch__suppliers', 'account_balance') }}