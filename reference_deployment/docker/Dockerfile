# Use Python 3.9 as the base image
FROM python:3.9-slim

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    ENVIRONMENT=production \
    LOG_LEVEL=INFO

# Set working directory
WORKDIR /app

# Install system dependencies including PostgreSQL client
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements file
COPY petstore-app/requirements.txt .

# Install Python dependencies with specific Werkzeug version
RUN pip install --no-cache-dir werkzeug==2.2.3 && \
    pip install --no-cache-dir -r requirements.txt && \
    pip install --no-cache-dir psycopg2-binary

# Copy application code
COPY petstore-app/ .

# Create a non-root user to run the application
RUN groupadd -r petstore && \
    useradd -r -g petstore -d /app -s /bin/bash petstore && \
    chown -R petstore:petstore /app

# Switch to non-root user
USER petstore

# Expose the application port
EXPOSE 8080

# Copy the entrypoint script
COPY deployment/docker/entrypoint.sh /app/entrypoint.sh

# Make the entrypoint script executable
USER root
RUN chmod +x /app/entrypoint.sh
USER petstore

# Set the entrypoint
ENTRYPOINT ["/app/entrypoint.sh"]

# Default command
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "--workers", "3", "--timeout", "120", "app:app"]
