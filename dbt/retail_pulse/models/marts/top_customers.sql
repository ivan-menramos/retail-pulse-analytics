WITH ranked AS (
    SELECT
        customer_id,
        country,
        customer_segment,
        monetary,
        frequency,
        recency_days,
        ROW_NUMBER() OVER (ORDER BY monetary DESC) AS rank
    FROM {{ ref('dim_customers') }}
    WHERE monetary IS NOT NULL
)

SELECT
    customer_id,
    country,
    customer_segment,
    monetary,
    frequency,
    recency_days,
    rank
FROM ranked
WHERE rank <= 10