---
title: Python Coding Standards
description: Python coding standards and best practices for this project
inclusion: fileMatch
fileMatchPattern: '*.py'
---

# Python Coding Standards

When working with Python files in this project, follow these guidelines:

## Code Style
- Follow PEP 8 style guidelines
- Use 4 spaces for indentation (no tabs)
- Maximum line length of 88 characters (Black formatter standard)
- Use snake_case for variables and function names
- Use CamelCase for class names
- Use UPPER_CASE for constants

## Documentation
- Use docstrings for all public modules, functions, classes, and methods
- Follow Google style docstrings format
- Include type hints for function parameters and return values

## Imports
- Group imports in the following order:
  1. Standard library imports
  2. Related third-party imports
  3. Local application/library specific imports
- Sort imports alphabetically within each group
- Use absolute imports rather than relative imports

## Error Handling
- Use specific exception types rather than bare except clauses
- Handle exceptions at the appropriate level
- Log exceptions with appropriate context

## Testing
- Write unit tests for all new functionality
- Use pytest as the testing framework
- Aim for high test coverage

## Database
- Use SQLAlchemy ORM for database operations
- Use migrations for database schema changes
- Avoid raw SQL queries when possible