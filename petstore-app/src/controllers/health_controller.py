"""
Health Controller - Provides health check endpoints with database connectivity verification
"""
from flask import Blueprint, jsonify
import os
import platform
import datetime
import logging
from src.utils.database import check_db_connection

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

health_bp = Blueprint('health_bp', __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    """Basic health check endpoint"""
    # Check database connectivity
    db_status = "connected" if check_db_connection() else "disconnected"
    
    status = "healthy" if db_status == "connected" else "unhealthy"
    
    response = {
        "status": status,
        "timestamp": datetime.datetime.now().isoformat(),
        "database": db_status
    }
    
    status_code = 200 if status == "healthy" else 503
    return jsonify(response), status_code

@health_bp.route('/health/details', methods=['GET'])
def detailed_health():
    """Detailed health check with system information and database status"""
    # Check database connectivity
    db_connected = check_db_connection()
    db_status = "connected" if db_connected else "disconnected"
    db_type = "PostgreSQL" if os.environ.get('DATABASE_URL', '').startswith('postgresql') else "SQLite"
    
    status = "healthy" if db_connected else "unhealthy"
    
    response = {
        "status": status,
        "timestamp": datetime.datetime.now().isoformat(),
        "system": {
            "platform": platform.system(),
            "platform_version": platform.version(),
            "python_version": platform.python_version(),
        },
        "environment": os.environ.get("ENVIRONMENT", "development"),
        "database": {
            "status": db_status,
            "type": db_type,
            "connection_string": os.environ.get('DATABASE_URL', 'sqlite:///petstore.db').split('@')[0].split('://')[0]  # Only show DB type, not credentials
        }
    }
    
    status_code = 200 if status == "healthy" else 503
    return jsonify(response), status_code
