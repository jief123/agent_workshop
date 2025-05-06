# IT Ops Acceleration with Amazon Q CLI Workshop

This workshop demonstrates how to use Amazon Q CLI and other AI agents to accelerate IT operations tasks. You'll learn how to take a simple microservice application and deploy it to AWS EKS using AI assistance throughout the process.

## Workshop Objectives

By the end of this workshop, you will:
- Understand how to leverage Amazon Q CLI for IT operations tasks
- Transform a simple application to be deployable on Amazon EKS
- Use Amazon Q CLI with AWS MCP Server to deploy solutions to AWS
- Learn best practices for AI-assisted infrastructure management

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Amazon Q CLI installed
- Docker installed
- kubectl installed
- Basic understanding of containerization and Kubernetes

## Workshop Architecture

This workshop uses a simple Pet Store microservice as the application to be deployed. The application is a RESTful API that allows users to manage pets in a store inventory.

### Application Components:
- RESTful API built with Python (Flask)
- SQLite database for local development
- Layered architecture (Controllers, Services, Models)

### Target Deployment Architecture:
- Amazon EKS for container orchestration
- Application deployed as Kubernetes pods
- Service and Ingress for external access
- AWS RDS for production database (optional extension)

## Design Documentation

The `design_docs` directory contains comprehensive documentation about the application architecture, API specifications, data models, and deployment requirements. These documents serve as the starting point for the transformation process.

Key design documents include:
- **architecture.md**: Overall application architecture and component interactions
- **api_spec.md**: API endpoints, request/response formats, and examples
- **data_model.md**: Database schema and entity relationships
- **deployment_requirements.md**: Infrastructure requirements and constraints

These design documents are crucial for Amazon Q CLI to understand the application context when assisting with transformation tasks.

## Workshop Modules

### Module 1: Understanding the Pet Store Microservice
- Explore the application architecture using the design documentation
- Run the application locally
- Test the API endpoints
- Review the code structure and dependencies

### Module 2: Transforming the Application for EKS
- Use Amazon Q CLI to analyze the design documents
- Learn to craft effective prompts for infrastructure tasks
- Generate a Dockerfile for containerization
- Create Kubernetes manifests for deployment
- Develop Terraform code for EKS infrastructure
- Review and refine the generated code

### Module 3: Deploying to AWS with Q CLI + MCP Server
- Understand AWS MCP (Model Context Provider) Server
- Use Amazon Q CLI with MCP Server for enhanced AWS assistance
- Validate and optimize infrastructure code
- Deploy the application to AWS EKS
- Verify and test the deployment
- Set up monitoring and continuous deployment

### Advanced Topics (Optional)
- Implementing CI/CD pipelines
- Adding monitoring and observability
- Configuring auto-scaling
- Setting up disaster recovery
- Implementing security best practices

## Using Amazon Q CLI for Transformation

Throughout this workshop, you'll use Amazon Q CLI to assist with various tasks. Here are some example prompts you can use:

1. Analyzing design documents:
   ```
   q "Analyze the design documents in the design_docs directory and summarize the key requirements for containerization and deployment"
   ```

2. Creating a Dockerfile:
   ```
   q "Based on the application requirements in design_docs/deployment_requirements.md, create a Dockerfile for the Pet Store application"
   ```

3. Generating Kubernetes manifests:
   ```
   q "Create Kubernetes deployment and service manifests for the Pet Store application based on the architecture described in design_docs/architecture.md"
   ```

4. Developing Terraform code:
   ```
   q "Generate Terraform code to provision an EKS cluster that meets the requirements in design_docs/deployment_requirements.md"
   ```

5. Deployment assistance:
   ```
   q "Help me deploy the application to EKS using the Terraform code and Kubernetes manifests we've created"
   ```

## Workshop Flow

This workshop is designed to be hands-on, with participants using Amazon Q CLI to generate all deployment code themselves. Rather than providing pre-created deployment artifacts, the workshop guides you through the process of using AI assistance to create and refine these artifacts.

The Pet Store microservice code and design documentation serve as the starting point, and Amazon Q CLI helps you transform and deploy the application based on this foundation.

## Getting Started

1. Clone this repository
2. Review the design documentation in the `design_docs` directory
3. Follow the instructions in `docs/module1.md` to begin the workshop

## Resources

- [Amazon Q CLI Documentation](https://aws.amazon.com/q/)
- [Amazon EKS Documentation](https://aws.amazon.com/eks/)
- [AWS MCP Server Documentation](https://aws.amazon.com/mcp/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
