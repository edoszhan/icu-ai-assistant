import pymysql
import os

# Load credentials from environment variables
db_host = os.getenv("RDS_HOST", "127.0.0.1")
db_user = os.getenv("RDS_USERNAME", "root")
db_password = os.getenv("RDS_PASSWORD", "")
db_name = os.getenv("RDS_DB_NAME", "your_database")

try:
    print(f"Trying to connect to MySQL at {db_host} as {db_user}...")
    connection = pymysql.connect(
        host=db_host,
        user=db_user,
        password=db_password,
        database=db_name,
        port=3306,  # Ensure the correct port is used
        connect_timeout=5
    )
    print("✅ Connection successful!")
    connection.close()
except Exception as e:
    print(f"❌ Failed to connect: {e}")
