from ingestion.utils import get_engine
from dotenv import load_dotenv
import os

load_dotenv()

try:
    server = os.getenv("DBSERVER")
    database = os.getenv("DB_name")
    engine = get_engine(server,database)
    with engine.connect() as conn:
        print("Conexion exitosa")
except Exception as e:
    print(f"Error: {e}")