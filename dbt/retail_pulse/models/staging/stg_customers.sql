WITH source AS (
    SELECT
        customer_id,
        country
    FROM [retail-pulse].dbo.customers
),

renamed AS (
    SELECT
        customer_id,
        TRIM(country) AS country,
        CASE
            WHEN country = 'United Kingdom' THEN 'domestic'
            ELSE 'international'
        END AS market_type
    FROM source
)

SELECT * FROM renamed