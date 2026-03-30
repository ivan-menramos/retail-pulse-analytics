from sqlalchemy import create_engine
from dotenv import load_dotenv
import os

load_dotenv()


def get_engine(server,database):
    
    return create_engine(
        f"mssql+pyodbc://@{server}/{database}"
        "?driver=ODBC+Driver+18+for+SQL+Server"
        "&trusted_connection=yes"
        "&TrustServerCertificate=yes"
    )