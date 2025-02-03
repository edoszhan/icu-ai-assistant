import pymysql
import os
# from sqlalchemy import create_engine
# from sqlalchemy.orm import sessionmaker

def connect_to_db():
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

# # SQLAlchemy connection setup
# DATABASE_URL = f"mysql+pymysql://{os.getenv('RDS_USERNAME')}:{os.getenv('RDS_PASSWORD')}@{os.getenv('RDS_HOST')}/{os.getenv('RDS_DB_NAME')}"

# engine = create_engine(DATABASE_URL, pool_recycle=3600, pool_size=10)
# SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# def get_db_session():
#     """Returns a new database session."""
#     return SessionLocal()
