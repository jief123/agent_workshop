---
title: Database Guidelines
description: Guidelines for working with databases in the project
inclusion: fileMatch
fileMatchPattern: '**/models/*.py'
---

# Database Guidelines

When working with database models and operations, follow these guidelines:

## SQLAlchemy Usage
- Use declarative models with SQLAlchemy ORM
- Define relationships explicitly
- Use appropriate column types
- Set appropriate constraints (unique, not null, etc.)
- Use indexes for frequently queried columns
- Use foreign keys to maintain referential integrity

## Query Optimization
- Use eager loading to avoid N+1 query problems
- Use query filtering at the database level
- Use pagination for large result sets
- Use appropriate joins instead of multiple queries
- Monitor and optimize slow queries

## Data Integrity
- Use transactions for operations that modify multiple records
- Validate data before inserting or updating
- Use database constraints to enforce business rules
- Handle race conditions appropriately
- Implement proper error handling for database operations

## Migrations
- Use Alembic for database migrations
- Create migrations for all schema changes
- Test migrations before applying to production
- Have rollback plans for migrations
- Document significant migrations

## Security
- Never store sensitive data in plaintext
- Use parameterized queries to prevent SQL injection
- Implement proper access controls
- Audit sensitive data access
- Regularly backup database

## Connection Management
- Use connection pooling
- Handle connection errors gracefully
- Close connections properly
- Monitor connection usage
- Set appropriate timeouts