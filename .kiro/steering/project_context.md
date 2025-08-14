---
title: Project Context
description: General information about the PetStore application project
inclusion: always
---

# PetStore Application Project

This is a Python-based pet store application with a Flask backend, SQLite database, and various deployment options including Docker and Kubernetes.

## Project Structure
- `petstore-app/`: Main application code
  - `app.py`: Entry point for the Flask application
  - `src/`: Source code organized by component type
  - `tests/`: Test suite for the application
- `design_docs/`: Architecture and design documentation
- `reference_deployment/`: Reference deployment configurations
- `workshop_modules/`: Workshop materials and guides

## Development Guidelines
- Follow PEP 8 style guidelines for Python code
- Write unit tests for all new functionality
- Document all public APIs and functions
- Use SQLAlchemy for database operations
- Follow RESTful API design principles

## Deployment Options
- Docker for containerization
- Kubernetes for orchestration
- Terraform for infrastructure as code

## Common Tasks
- Run the application: `python petstore-app/app.py`
- Run tests: `pytest petstore-app/tests/`
- Build Docker image: `docker build -t petstore-app .`