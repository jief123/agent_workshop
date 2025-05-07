"""
Database Utility - Handles database connection and initialization
Supports both SQLite for development and PostgreSQL for production
"""
import os
import logging
from sqlalchemy import create_engine, text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker, scoped_session
from sqlalchemy.pool import NullPool, QueuePool

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Get database URL from environment or use SQLite by default
DATABASE_URL = os.environ.get('DATABASE_URL', 'sqlite:///petstore.db')

# Create engine with appropriate configuration based on database type
if DATABASE_URL.startswith('postgresql'):
    # PostgreSQL configuration with connection pooling
    logger.info("Configuring PostgreSQL database connection")
    engine = create_engine(
        DATABASE_URL,
        poolclass=QueuePool,
        pool_size=5,
        max_overflow=10,
        pool_timeout=30,
        pool_recycle=1800,  # Recycle connections after 30 minutes
        echo=False
    )
else:
    # SQLite configuration (no pooling needed)
    logger.info("Configuring SQLite database connection")
    engine = create_engine(
        DATABASE_URL,
        poolclass=NullPool,  # No pooling for SQLite
        connect_args={"check_same_thread": False},  # Allow multi-threading for SQLite
        echo=False
    )

# Create session factory
session_factory = sessionmaker(bind=engine)
Session = scoped_session(session_factory)

# Create base class for models
Base = declarative_base()

def init_db():
    """Initialize the database by creating all tables"""
    try:
        Base.metadata.create_all(engine)
        logger.info("Database tables created successfully")
    except Exception as e:
        logger.error(f"Error initializing database: {str(e)}")
        raise

def get_session():
    """Get a new database session"""
    return Session()

def close_session(session):
    """Close a database session"""
    if session:
        session.close()

def check_db_connection():
    """Check if database connection is working"""
    try:
        # Try to connect and execute a simple query
        connection = engine.connect()
        connection.execute(text("SELECT 1"))
        connection.close()
        return True
    except Exception as e:
        logger.error(f"Database connection check failed: {str(e)}")
        return False
