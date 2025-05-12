# Workshop Plan: Accelerating IT Ops with Amazon Q CLI

## Overview
This workshop demonstrates how to use Amazon Q CLI and other AI agents to accelerate IT operations tasks. Participants will transform a simple Pet Store microservice into a solution deployable on AWS EKS, using AI assistance throughout the process.

## Project Structure
```
agent_workshop/
├── README.md                     # Main workshop instructions
├── petstore-app/                 # Simple microservice source code
│   ├── src/                      # Application source code
│   │   ├── controllers/          # API controllers
│   │   ├── models/               # Data models
│   │   ├── services/             # Business logic
│   │   └── utils/                # Helper functions
│   ├── tests/                    # Unit tests
│   ├── requirements.txt          # Dependencies
│   └── app.py                    # Main application entry point
├── design_docs/                  # Design documentation
│   ├── architecture.md           # Application architecture
│   ├── api_spec.md               # API specifications
│   ├── data_model.md             # Data model documentation
│   ├── deployment_requirements.md # Deployment requirements
│   └── diagrams/                 # Architecture diagrams
│       ├── application_flow.txt  # Application flow diagram
│       └── deployment_arch.txt   # Deployment architecture diagram
├── deployment/                   # Deployment resources (empty directories for participants to fill)
│   ├── docker/                   # For Dockerfile
│   ├── kubernetes/               # For Kubernetes manifests
│   ├── terraform/                # For Terraform code
│   ├── scripts/                  # For helper scripts
│   └── workflows/                # For deployment workflows
└── docs/                         # Workshop documentation
    ├── module1.md                # Module 1: Understanding the application
    ├── module2.md                # Module 2: Transforming for EKS
    ├── module3.md                # Module 3: Deploying with Q CLI + MCP
    └── advanced_topics.md        # Additional topics and extensions
```

## Implementation Plan

### Step 1: Create the Pet Store Microservice
- Develop a simple RESTful API for a pet store using Python (Flask)
- Implement basic CRUD operations for pet management
- Include a simple database layer (SQLite for local development)
- Add comprehensive API documentation
- Create unit tests for core functionality
- Ensure the application runs locally without containerization

### Step 2: Create Design Documentation
- **architecture.md**:
  - Component diagram showing API, business logic, and data layers
  - Request flow from client to database and back
  - Integration points and dependencies
  - Scalability considerations
  - Security architecture

- **api_spec.md**:
  - RESTful endpoints (GET /pets, POST /pets, GET /pets/{id}, etc.)
  - Request and response formats with JSON examples
  - Query parameters and pagination
  - Error handling and status codes
  - Authentication and authorization requirements

- **data_model.md**:
  - Entity relationship diagrams
  - Database schema definitions
  - Object models and their relationships
  - Data validation rules
  - Sample data

- **deployment_requirements.md**:
  - Compute resources (CPU, memory)
  - Storage requirements
  - Networking configuration
  - Scaling parameters
  - Environment variables and configuration
  - Security requirements
  - Monitoring and logging needs
  - Backup and disaster recovery considerations

### Step 3: Prepare Workshop Documentation
- Create step-by-step guides for each module
- Include example Amazon Q CLI prompts for participants to use
- Document expected outcomes and validation steps
- Create troubleshooting guides for common issues

### Step 4: Create Empty Deployment Structure
- Set up empty directories for deployment resources
- Participants will use Amazon Q CLI to generate all deployment code themselves
- No pre-created deployment artifacts should be provided

## Workshop Flow

### Module 1: Understanding the Pet Store Microservice
- Introduction to the application architecture
- Review of the design documentation
- Local setup and testing
- Exploration of code structure and dependencies
- Understanding deployment requirements

### Module 2: Transforming the Application for EKS
- Using Amazon Q CLI to analyze design documents
- Learning to craft effective prompts for infrastructure tasks
- Database refactoring:
  - Refactoring the application to support PostgreSQL for production
  - Creating database migration scripts
  - Enhancing health checks for database connectivity
- Containerization with Docker:
  - Creating an optimized Dockerfile using Amazon Q CLI
  - Building and testing the container locally
- Kubernetes configuration:
  - Creating deployment manifests using Amazon Q CLI
  - Configuring services and ingress using Amazon Q CLI
  - Setting up ConfigMaps and Secrets using Amazon Q CLI
- Infrastructure as Code with Terraform:
  - VPC and networking setup using Amazon Q CLI
  - EKS cluster configuration using Amazon Q CLI
  - RDS PostgreSQL instance setup using Amazon Q CLI
  - Security and IAM configuration using Amazon Q CLI
  - Resource optimization using Amazon Q CLI

### Module 3: Building a Pet Store Agent with MCP and Rapid Assistant
- Introduction to MCP (Model Context Protocol)
- Overview of Rapid Assistant SDK
- Setting up the development environment
- Creating a Pet Store API client
- Defining MCP tools for Pet Store operations
- Building the MCP server
- Configuring Amazon Q CLI to use the custom MCP server
- Advanced features and AWS service integration
- Hands-on exercises

### Module 4: Build Your Own Agent - Customer Use Case Challenge
- Group formation (3-5 participants per group)
- Use case identification and selection
- Agent design (15 minutes)
- Agent implementation (45 minutes)
- Presentation preparation (10 minutes)
- Group presentations (5 minutes per group + 2 minutes Q&A)
- Evaluation and feedback

### Advanced Topics (Optional)
- Implementing CI/CD pipelines
- Adding monitoring and observability
- Configuring auto-scaling
- Setting up disaster recovery
- Implementing security best practices

## Example Amazon Q CLI Prompts

### For Design Document Analysis
```
q "Analyze the design documents in the design_docs directory and summarize the key requirements for containerization and deployment"
```

### For Database Refactoring
```
q "Analyze the database connection code in the Pet Store application and refactor it to support both SQLite for development and PostgreSQL for production"
```

q "Create a Python script to migrate data from SQLite to PostgreSQL for the Pet Store application"
```

### For Dockerfile Creation
```
q "Based on the application requirements in design_docs/deployment_requirements.md, create a Dockerfile for the Pet Store application that includes PostgreSQL support"
```

### For Kubernetes Manifest Generation
```
q "Create Kubernetes deployment and service manifests for the Pet Store application based on the architecture described in design_docs/architecture.md and the requirements in design_docs/deployment_requirements.md"
```

### For Terraform Development
```
q "Generate Terraform code to provision an EKS cluster and RDS PostgreSQL instance that meets the requirements in design_docs/deployment_requirements.md"
```

### For MCP Agent Development
```
q "Help me create an MCP server using Rapid Assistant SDK that exposes the Pet Store API operations as tools"
```

### For Custom Agent Use Cases
```
q "Design an MCP agent that could help with cloud cost optimization by analyzing AWS Cost Explorer data"
```

q "Create a tool definition for an MCP agent that can check the health of microservices"
```

- Test the Pet Store application to ensure it runs locally
- Validate that the design documentation provides sufficient context for Amazon Q CLI
- Test example Amazon Q CLI prompts to ensure they produce expected results
- Create checkpoints throughout the workshop for participants to validate their progress

## Workshop Extensions

- Multi-region deployment
- Blue-green deployment strategies
- Integration with AWS services like RDS, ElastiCache, etc.
- Implementing API Gateway and Lambda for serverless components
- Setting up monitoring with CloudWatch and Prometheus
- Implementing automated backup and recovery procedures
- Building specialized agents for different business domains
- Creating agent networks that collaborate to solve complex problems
- Implementing agent memory and context management
- Developing agents that can learn from user interactions
