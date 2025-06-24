import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.models import Base
from tenacity import retry, wait_fixed, stop_after_attempt

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:postgres@localhost:5432/postgres"
)
engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(
    autocommit=False, autoflush=False, bind=engine
)


@retry(wait=wait_fixed(2), stop=stop_after_attempt(5))
def init_db():
    Base.metadata.create_all(bind=engine)
