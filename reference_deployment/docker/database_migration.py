#!/usr/bin/env python3
"""
Database Migration Script - Migrates data from SQLite to PostgreSQL
"""
import os
import sys
import logging
import argparse
import sqlite3
import psycopg2
from psycopg2.extras import execute_values

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

def get_sqlite_tables(sqlite_conn):
    """Get all tables from SQLite database"""
    cursor = sqlite_conn.cursor()
    cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")
    tables = cursor.fetchall()
    return [table[0] for table in tables if table[0] != 'sqlite_sequence']

def get_table_schema(sqlite_conn, table_name):
    """Get schema for a specific table"""
    cursor = sqlite_conn.cursor()
    cursor.execute(f"PRAGMA table_info({table_name});")
    columns = cursor.fetchall()
    return [(col[1], col[2]) for col in columns]

def get_table_data(sqlite_conn, table_name):
    """Get all data from a specific table"""
    cursor = sqlite_conn.cursor()
    cursor.execute(f"SELECT * FROM {table_name};")
    return cursor.fetchall()

def create_postgres_table(pg_conn, table_name, schema):
    """Create table in PostgreSQL with the same schema as SQLite"""
    # Map SQLite types to PostgreSQL types
    type_mapping = {
        'INTEGER': 'INTEGER',
        'TEXT': 'TEXT',
        'REAL': 'REAL',
        'BLOB': 'BYTEA',
        'BOOLEAN': 'BOOLEAN',
        'DATETIME': 'TIMESTAMP',
        'DATE': 'DATE',
        'TIME': 'TIME',
        'NUMERIC': 'NUMERIC',
        'VARCHAR': 'VARCHAR',
        'CHAR': 'CHAR'
    }
    
    cursor = pg_conn.cursor()
    
    # Create column definitions
    columns = []
    for col_name, col_type in schema:
        # Extract base type (remove size constraints, etc.)
        base_type = col_type.split('(')[0].upper()
        pg_type = type_mapping.get(base_type, 'TEXT')
        
        # Add size constraint back if it exists
        if '(' in col_type:
            size_part = col_type.split('(')[1].split(')')[0]
            pg_type = f"{pg_type}({size_part})"
            
        columns.append(f"{col_name} {pg_type}")
    
    # Add primary key if it exists
    if 'id' in [col[0] for col in schema]:
        columns = [col if not col.startswith('id ') else f"{col} PRIMARY KEY" for col in columns]
    
    # Create the table
    create_query = f"CREATE TABLE IF NOT EXISTS {table_name} ({', '.join(columns)});"
    logger.info(f"Creating table {table_name} with query: {create_query}")
    cursor.execute(create_query)
    pg_conn.commit()

def insert_data(pg_conn, table_name, schema, data):
    """Insert data into PostgreSQL table"""
    if not data:
        logger.info(f"No data to insert for table {table_name}")
        return
    
    cursor = pg_conn.cursor()
    columns = [col[0] for col in schema]
    
    # Prepare query for batch insert
    query = f"INSERT INTO {table_name} ({', '.join(columns)}) VALUES %s"
    
    # Execute batch insert
    logger.info(f"Inserting {len(data)} rows into {table_name}")
    execute_values(cursor, query, data)
    pg_conn.commit()

def migrate_database(sqlite_path, pg_conn_string):
    """Migrate all data from SQLite to PostgreSQL"""
    try:
        # Connect to SQLite database
        logger.info(f"Connecting to SQLite database: {sqlite_path}")
        sqlite_conn = sqlite3.connect(sqlite_path)
        
        # Connect to PostgreSQL database
        logger.info(f"Connecting to PostgreSQL database")
        pg_conn = psycopg2.connect(pg_conn_string)
        
        # Get all tables from SQLite
        tables = get_sqlite_tables(sqlite_conn)
        logger.info(f"Found tables: {tables}")
        
        # Migrate each table
        for table in tables:
            logger.info(f"Migrating table: {table}")
            
            # Get table schema and data
            schema = get_table_schema(sqlite_conn, table)
            data = get_table_data(sqlite_conn, table)
            
            # Create table in PostgreSQL
            create_postgres_table(pg_conn, table, schema)
            
            # Insert data into PostgreSQL
            insert_data(pg_conn, table, schema, data)
            
            logger.info(f"Successfully migrated table: {table}")
        
        logger.info("Migration completed successfully")
        
    except Exception as e:
        logger.error(f"Error during migration: {str(e)}")
        raise
    finally:
        # Close connections
        if 'sqlite_conn' in locals():
            sqlite_conn.close()
        if 'pg_conn' in locals():
            pg_conn.close()

def main():
    """Main function to run the migration script"""
    parser = argparse.ArgumentParser(description='Migrate data from SQLite to PostgreSQL')
    parser.add_argument('--sqlite-path', required=True, help='Path to SQLite database file')
    parser.add_argument('--pg-conn-string', required=True, help='PostgreSQL connection string')
    
    args = parser.parse_args()
    
    try:
        migrate_database(args.sqlite_path, args.pg_conn_string)
    except Exception as e:
        logger.error(f"Migration failed: {str(e)}")
        sys.exit(1)

if __name__ == '__main__':
    main()
