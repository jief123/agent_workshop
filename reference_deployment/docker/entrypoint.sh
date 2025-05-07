#!/bin/bash
set -e

# Function to check if PostgreSQL is ready
check_postgres() {
    PGPASSWORD=$DB_PASSWORD psql -h $DB_HOST -U $DB_USER -d $DB_NAME -c "SELECT 1" >/dev/null 2>&1
    return $?
}

# If DATABASE_URL starts with postgresql, wait for PostgreSQL to be ready
if [[ "${DATABASE_URL}" == postgresql* ]]; then
    echo "Waiting for PostgreSQL to be ready..."
    
    # Extract database connection details from DATABASE_URL
    # Format: postgresql://username:password@host:port/dbname
    DB_USER=$(echo $DATABASE_URL | sed -E 's/postgresql:\/\/([^:]+):.*/\1/')
    DB_PASSWORD=$(echo $DATABASE_URL | sed -E 's/postgresql:\/\/[^:]+:([^@]+).*/\1/')
    DB_HOST=$(echo $DATABASE_URL | sed -E 's/postgresql:\/\/[^@]+@([^:\/]+).*/\1/')
    DB_PORT=$(echo $DATABASE_URL | sed -E 's/.*:([0-9]+)\/.*/\1/;s/.*@([^\/]+)\/.*/\1/' | grep -oE '[0-9]+')
    DB_NAME=$(echo $DATABASE_URL | sed -E 's/.*\/([^?]+).*/\1/')
    
    # Set default port if not specified
    DB_PORT=${DB_PORT:-5432}
    
    # Wait for PostgreSQL to be ready
    until check_postgres; do
        echo "PostgreSQL is unavailable - sleeping"
        sleep 2
    done
    
    echo "PostgreSQL is up - continuing"
fi

# Initialize the database
echo "Initializing database..."
python -c "from src.utils.database import init_db; init_db()"

# Execute the command
echo "Starting application..."
exec "$@"
