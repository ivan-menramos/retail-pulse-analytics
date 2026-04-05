WITH customers AS (
    SELECT * FROM {{ref ('stg_customers')}}
),

orders AS (
    SELECT * FROM {{ref ('fct_orders')}}
    WHERE is_cancelled = 0 AND customer_id IS NOT NULL
),

rfm AS (
    SELECT
        customer_id,
        MAX(invoiced_date) AS last_purchase_date,
        DATEDIFF(DAY, MAX(invoiced_date),'2011-12-31') AS recency_days,
        COUNT(DISTINCT invoice_number) AS frequency,
        SUM(revenue) AS monetary
    FROM orders
    GROUP BY customer_id
),

rfm_scores AS (
    SELECT
        customer_id,
        last_purchase_date,
        recency_days,
        frequency,
        monetary,

        NTILE(4) OVER (ORDER BY recency_days DESC) AS r_score, -- DESC: días altos=score bajo=peor
        NTILE(4) OVER (ORDER BY frequency ASC)     AS f_score, -- ASC: frecuencia alta=score alto=mejor  
        NTILE(4) OVER (ORDER BY monetary ASC)      AS m_score  -- ASC: monetary alto=score alto=mejor
    FROM rfm
),

segmented AS (
    SELECT
        customer_id,
        last_purchase_date,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        CAST(r_score AS VARCHAR) + CAST(f_score AS VARCHAR) + CAST(m_score AS VARCHAR) AS rfm_segment,

        CASE
            WHEN r_score = 4 AND f_score = 4 THEN 'Champion'
            WHEN r_score >= 3 AND f_score >= 3  THEN 'Loyal'
            WHEN r_score >= 3 AND f_score < 3  THEN 'Potential Loyalist'
            WHEN r_score < 3  AND f_score >= 3  THEN 'At Risk'
            WHEN r_score = 1  AND f_score = 1  THEN 'Lost'
            ELSE 'Needs Attention'
        END AS customer_segment
    FROM rfm_scores
),

final AS (
    SELECT
        c.customer_id,
        c.country,
        c.market_type,
        s.last_purchase_date,
        s.recency_days,
        s.frequency,
        s.monetary,
        s.r_score,
        s.f_score,
        s.m_score,
        s.rfm_segment,
        s.customer_segment
    FROM customers c
    LEFT JOIN segmented s ON c.customer_id = s.customer_id
)

SELECT * FROM final