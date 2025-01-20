import pymysql
import os

def connect_to_db():
    # RDS connection details
    try:
        connection = pymysql.connect(
            host=os.getenv("RDS_HOST"),
            user=os.getenv("RDS_USERNAME"),
            password=os.getenv("RDS_PASSWORD"),
            database=os.getenv("RDS_DB_NAME"),
            connect_timeout=5
        )
        return connection
    except Exception as e:
        raise Exception(f"Failed to connect to database: {str(e)}")