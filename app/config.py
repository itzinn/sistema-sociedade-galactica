import os
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class Config:
    ORACLE_USER = os.getenv('ORACLE_USER')
    ORACLE_PASSWORD = os.getenv('ORACLE_PASSWORD')
    ORACLE_DSN = os.getenv('ORACLE_DSN')