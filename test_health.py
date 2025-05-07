#!/usr/bin/env python3
import os
import sys

# Change to the petstore-app directory
os.chdir('/home/ubuntu/agent_workshop/petstore-app')

# Add the current directory to the Python path
sys.path.insert(0, os.getcwd())

from flask import Flask
from src.controllers.health_controller import health_bp

app = Flask(__name__)
app.register_blueprint(health_bp, url_prefix='/api/v1')

with app.test_client() as client:
    response = client.get('/api/v1/health')
    print(f"Status code: {response.status_code}")
    print(f"Response: {response.get_data(as_text=True)}")
