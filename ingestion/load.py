# ingestion/load.py
import pandas as pd
from utils import get_engine
from sqlalchemy import text
import os

def load_customers(customers: pd.DataFrame, engine):
    existing = pd.read_sql("SELECT customer_id FROM customers", engine)
    new_rows = customers[~customers["customer_id"].isin(existing["customer_id"])]
    if len(new_rows) > 0:
        new_rows.to_sql("customers", con=engine, if_exists="append", index=False, schema="dbo")
    print(f"[load] Customers: {len(new_rows):,} nuevos / {len(existing):,} ya existían")

def load_products(products: pd.DataFrame, engine):
    existing = pd.read_sql("SELECT stock_code FROM products", engine)
    new_rows = products[~products["stock_code"].isin(existing["stock_code"])]
    if len(new_rows) > 0:
        new_rows.to_sql("products", con=engine, if_exists="append", index=False, schema="dbo")
    print(f"[load] Products: {len(new_rows):,} nuevos / {len(existing):,} ya existían")

def load_orders(orders: pd.DataFrame, engine):
    existing = pd.read_sql("SELECT order_id, stock_code FROM orders", engine)
    existing["key"] = existing["order_id"] + "_" + existing["stock_code"]
    orders["key"]   = orders["order_id"]   + "_" + orders["stock_code"]
    new_rows = orders[~orders["key"].isin(existing["key"])].drop(columns=["key"])
    if len(new_rows) > 0:
        new_rows.to_sql("orders", con=engine, if_exists="append", index=False, schema="dbo", chunksize=1000)
    print(f"[load] Orders: {len(new_rows):,} nuevos / {len(existing):,} ya existían")

def load_data(customers: pd.DataFrame, products: pd.DataFrame, orders: pd.DataFrame):
    server = os.getenv("DBSERVER")
    database = os.getenv("DB_name")
    engine = get_engine(server,database)
    print("PROCESO DE CARGA(IDEMPOTENTE) COMENZANDO")
    load_customers(customers, engine)
    load_products(products, engine)
    load_orders(orders, engine)
    print("[load] Carga completa.")

if __name__ == "__main__":
    from extract import extraer_datos
    from transform import transformar_datos

    df = extraer_datos()
    customers, products, orders = transformar_datos(df)
    load_data(customers, products, orders)