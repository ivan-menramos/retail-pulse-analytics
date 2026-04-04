WITH source AS (
    SELECT
        order_line_id,
        order_id,
        stock_code,
        customer_id,
        quantity,
        unit_price,
        invoice_date,
        is_cancelled
    FROM [retail-pulse].dbo.orders
),

renamed AS (
    SELECT
        order_line_id,
        order_id AS [invoice number],
        stock_code AS [product id],
        customer_id,
        quantity,
        unit_price,
        CAST(quantity * unit_price AS DECIMAL(10,2)) AS [line total],
        invoice_date,
        CAST(invoice_date AS DATE) AS invoiced_date,
        is_cancelled
    FROM source

)

SELECT * FROM renamed