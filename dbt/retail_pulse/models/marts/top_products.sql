WITH ranked AS (
    SELECT
        product_id,
        product_name,
        abc_category,
        total_revenue,
        total_units_sold,
        total_orders,
        ROW_NUMBER() OVER (ORDER BY total_revenue DESC) AS rank
    FROM {{ ref('dim_products') }}
    WHERE total_revenue IS NOT NULL
      AND total_revenue > 0
)

SELECT
    product_id,
    product_name,
    abc_category,
    total_revenue,
    total_units_sold,
    total_orders,
    rank
FROM ranked
WHERE rank <= 10