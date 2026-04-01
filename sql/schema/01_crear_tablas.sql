USE retail_pulse;


CREATE TABLE customers (
    customer_id   INT             NOT NULL,
    country       NVARCHAR(100)   NOT NULL,

    CONSTRAINT pk_customers PRIMARY KEY (customer_id)
);


CREATE TABLE products (
    stock_code    NVARCHAR(20)    NOT NULL,
    description   NVARCHAR(255),

    CONSTRAINT pk_products PRIMARY KEY (stock_code)
);
GO

CREATE TABLE orders (
    order_id        NVARCHAR(20)    NOT NULL,
    stock_code      NVARCHAR(20)    NOT NULL,
    customer_id     INT,
    quantity        INT             NOT NULL,
    unit_price      DECIMAL(10, 2)  NOT NULL,
    invoice_date    DATETIME        NOT NULL,
    is_cancelled    BIT             NOT NULL DEFAULT 0,

    CONSTRAINT pk_orders
        PRIMARY KEY (order_id, stock_code),

    CONSTRAINT fk_orders_products
        FOREIGN KEY (stock_code)
        REFERENCES products(stock_code),

    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
);
