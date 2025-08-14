---
title: API Design Guidelines
description: Guidelines for designing and implementing APIs
inclusion: fileMatch
fileMatchPattern: '**/controllers/*.py'
---

# API Design Guidelines

When working with API controllers, follow these guidelines:

## RESTful Design
- Use appropriate HTTP methods (GET, POST, PUT, DELETE, PATCH)
- Use nouns, not verbs, in endpoint paths
- Use plural nouns for collection endpoints
- Use hierarchical structure for related resources
- Return appropriate HTTP status codes

## Request Handling
- Validate all input data
- Use query parameters for filtering, sorting, and pagination
- Use request bodies for complex data structures
- Support content negotiation (JSON, XML, etc.)

## Response Format
- Use consistent response format
- Include metadata when appropriate (pagination info, etc.)
- Use hypermedia links when appropriate (HATEOAS)
- Return appropriate error messages and codes

## Security
- Implement proper authentication and authorization
- Validate and sanitize all input
- Protect against common vulnerabilities (CSRF, XSS, etc.)
- Rate limit requests when necessary

## Documentation
- Document all endpoints with OpenAPI/Swagger
- Include example requests and responses
- Document error responses and codes
- Keep documentation up-to-date with implementation

## Versioning
- Include version in URL path or header
- Maintain backward compatibility when possible
- Document breaking changes