"""
Health Controller - Provides health check endpoints
"""
from flask import Blueprint, jsonify
import os
import platform
import datetime

health_bp = Blueprint('health_bp', __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    """Basic health check endpoint"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat()
    })

@health_bp.route('/health/details', methods=['GET'])
def detailed_health():
    """Detailed health check with system information"""
    return jsonify({
        "status": "healthy",
        "timestamp": datetime.datetime.now().isoformat(),
        "system": {
            "platform": platform.system(),
            "platform_version": platform.version(),
            "python_version": platform.python_version(),
        },
        "environment": os.environ.get("ENVIRONMENT", "development")
    })
