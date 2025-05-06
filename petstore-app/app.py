#!/usr/bin/env python3
"""
Pet Store API - Main Application Entry Point
"""
from flask import Flask, jsonify
from src.controllers.pet_controller import pet_bp
from src.controllers.health_controller import health_bp
from src.utils.database import init_db

app = Flask(__name__)

# Register blueprints
app.register_blueprint(pet_bp, url_prefix='/api/v1')
app.register_blueprint(health_bp, url_prefix='/api/v1')

# Initialize database
init_db()

@app.errorhandler(404)
def not_found(error):
    return jsonify({"error": "Resource not found"}), 404

@app.errorhandler(500)
def server_error(error):
    return jsonify({"error": "Internal server error"}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080, debug=True)
