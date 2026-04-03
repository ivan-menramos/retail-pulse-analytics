import pandas as pd

def transformar_datos(df: pd.DataFrame):
    """
    ARGUMENTOS
    """
    print("Comenzando proceso de transformación")

    """
    Eliminamos filas con nulos, la justificación para eliminar description
    es porque en el eda aparece que su relevancia es del 0%
    """
    print("Filas a eliminarse de Description:",df["Description"].isnull().sum())
    df = df.dropna(subset = ["Description"])

    #Convertimos InvoiceDate de str a datetime
    df["InvoiceDate"] = pd.to_datetime(df["InvoiceDate"], format = "%m/%d/%Y %H:%M")

    #Buscar cancelaciones
    df["is_cancelled"] = df["InvoiceNo"].str.startswith("C").astype(int)

    #Limpiamos InvoiceNo
    df["InvoiceNo"] = df["InvoiceNo"].str.replace("^C","", regex = True)

    #Filtramos precios negativos o cero en ordenes no canceladas
    df = df[~((df["UnitPrice"] <= 0) & (df["is_cancelled"] == 0))]

    df["CustomerID"] = pd.to_numeric(df["CustomerID"],errors = "coerce").astype("Int64")

    df["Description"] = df["Description"].str.strip().str.upper()
    df["Country"] = df["Country"].str.strip()


    #Lo siguiente es separar en tres DataFrames

    #Customers
    customers = (
        df.dropna(subset=["CustomerID"])
        [["CustomerID" , "Country"]]
        .drop_duplicates(subset=["CustomerID"])
        .rename(columns={"CustomerID" : "customer_id","Country" : "country"})
        .reset_index(drop = True)
    )

    #products
    products = (
        df[["StockCode","Description"]]
        .drop_duplicates(subset="StockCode")
        .rename(columns = {"StockCode" : "stock_code","Description" : "description"})
        .reset_index(drop = True)
    )

    #orders
    orders = (
        df.rename(columns={
            "InvoiceNo" : "order_id",
            "StockCode" : "stock_code",
            "CustomerID" : "customer_id",
            "Quantity" : "quantity",
            "UnitPrice" : "unit_price",
            "InvoiceDate" : "invoice_date",
        })
        [["order_id","stock_code","customer_id","quantity"
          ,"unit_price","invoice_date"]]
    )

    return customers, products, orders

if __name__ == "__main__":
    from extract import extraer_datos
    df = extraer_datos()
    customers, products, orders = transformar_datos(df)
    print(customers.head())
    print(products.head())
    print(orders.head())
