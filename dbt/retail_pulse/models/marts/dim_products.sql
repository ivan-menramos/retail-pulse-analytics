-- models/marts/dim_products.sql
WITH products AS (
    SELECT * FROM {{ ref('stg_products') }}
),

orders AS (
    SELECT * FROM {{ ref('fct_orders') }}
    WHERE is_cancelled = 0
),

product_metrics AS (
    SELECT
        product_id,
        COUNT(DISTINCT invoice_number) AS total_orders,
        SUM(quantity) AS total_units_sold,
        SUM(revenue) AS total_revenue
    FROM orders
    WHERE product_id IS NOT NULL
    GROUP BY product_id
),

abc AS (
    SELECT
        product_id,
        total_orders,
        total_units_sold,
        total_revenue,
        SUM(total_revenue) OVER () AS grand_total_revenue,
        SUM(total_revenue) OVER (
            ORDER BY total_revenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        )  AS cumulative_revenue
    FROM product_metrics
),

abc_classified AS (
    SELECT
        product_id,
        total_orders,
        total_units_sold,
        total_revenue,
        ROUND(total_revenue / grand_total_revenue * 100, 2) AS revenue_pct,
        ROUND(cumulative_revenue / grand_total_revenue * 100, 2) AS cumulative_pct,
        CASE
            WHEN cumulative_revenue / grand_total_revenue <= 0.80 THEN 'A'
            WHEN cumulative_revenue / grand_total_revenue <= 0.95 THEN 'B'
            ELSE 'C'
        END                                     AS abc_category
    FROM abc
),

final AS (
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(a.total_orders, 0) AS total_orders,
        COALESCE(a.total_units_sold, 0) AS total_units_sold,
        COALESCE(a.total_revenue, 0) AS total_revenue,
        a.revenue_pct,
        a.cumulative_pct,
        COALESCE(a.abc_category, 'C') AS abc_category
    FROM products p
    LEFT JOIN abc_classified a ON p.product_id = a.product_id
)

SELECT * FROM final