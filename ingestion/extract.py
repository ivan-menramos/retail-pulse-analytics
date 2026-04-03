import pandas as pd
import os

raw_path = os.path.join("data","raw","data.csv")

def extraer_datos() -> pd.DataFrame:
    """
    ARGUMENTOS
    """
    print(f"Proceso de extracción comenzando")

    df = pd.read_csv(raw_path, encoding = "latin-1",
                     dtype={
                         "InvoiceNo" : str,
                         "StockCode" : str,
                         "Description" : str,
                         "Quantity" : int,
                         "InvoiceDate" : str,
                         "UnitPrice" : float,
                         "CustomerID" : str,
                         "Country" : str
                     }
                     )

    print(f"Se cargaron {len(df)} filas")
    print(f"Las columnas son {list(df.columns)}")

    return df

if __name__ == "__main__":
    df = extraer_datos()
    print(df.head())