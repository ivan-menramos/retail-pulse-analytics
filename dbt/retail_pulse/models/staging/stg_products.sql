WITH source AS (
    SELECT 
        stock_code,
        description
    FROM [retail-pulse].dbo.products
),
renamed AS (
    SELECT
        stock_code AS product_id,
        TRIM(description) AS product_name
    FROM source
    WHERE description NOT LIKE '%TEST%'
        AND description NOT LIKE '%ADJUST%'       
)

SELECT * FROM renamed