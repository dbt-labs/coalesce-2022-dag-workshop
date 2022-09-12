

SELECT order_key, 
       order_date
FROM {{ ref('fct_orders') }}