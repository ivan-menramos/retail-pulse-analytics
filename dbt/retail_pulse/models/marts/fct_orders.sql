WITH orders AS (
    SELECT * FROM {{ref ('stg_orders')}}
),

customers AS (
    SELECT * FROM {{ref ('stg_customers')}}
),

products AS (
    SELECT * FROM {{ref ('stg_products')}}
),

final AS (
    SELECT
        o.order_line_id,
        o.invoice_number,
        o.invoice_date,
        o.invoiced_date,
        o.is_cancelled,

        o.product_id,
        p.product_name,

        o.customer_id,
        c.country,
        c.market_type,

        o.quantity,
        o.unit_price,
        o.line_total,

        CASE 
            WHEN o.is_cancelled = 0 THEN o.line_total
            ELSE 0
        END AS revenue
    FROM orders AS o
    LEFT JOIN products AS p ON o.product_id = p.product_id
    LEFT JOIN customers AS c ON o.customer_id = c.customer_id

)

SELECT * FROM final
