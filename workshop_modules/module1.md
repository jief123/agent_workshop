# Module 1: Understanding the Pet Store Microservice

## Overview

In this module, you will explore the Pet Store microservice application, understand its architecture, and run it locally using Amazon Q CLI to assist you throughout the process. This will provide the foundation for the transformation and deployment work in later modules.

## Learning Objectives

By the end of this module, you will be able to:
- Use Amazon Q CLI to understand the application architecture
- Identify key components and their interactions with AI assistance
- Set up and run the application locally with Amazon Q guidance
- Test the API endpoints using Amazon Q-generated commands
- Understand deployment requirements through AI-assisted analysis

## Prerequisites

- Python 3.9 or later installed
- Amazon Q CLI installed and configured
- Basic understanding of RESTful APIs
- Familiarity with Python web applications

## Setting Up Amazon Q CLI Context

Before starting the workshop, you need to set up Amazon Q CLI to understand the project context:

```bash
# Navigate to your home directory or wherever you want to work
cd /path/to/agent_workshop
q chat

# Add the agent_workshop directory to Amazon Q CLI context
/context add /path/to/agent_workshop

# Verify the context is properly set
/context show
```

This step is crucial as it allows Amazon Q CLI to access and understand the project files, including the README, design documents, and application code. With this context, Amazon Q can provide more accurate and relevant assistance throughout the workshop.

## Step 1: Explore the Application Architecture

### Setting Up Project Context for Amazon Q

Before analyzing the architecture, ensure Amazon Q has full context of the project:

```bash
# First, explore the project structure to understand what's available
q "Can you list all the directories and key files in the agent_workshop project and explain their purpose?"
```

This will help you understand the overall project organization and ensure Amazon Q has properly indexed the project files.

### Using Amazon Q CLI to Analyze the Architecture

Now use Amazon Q CLI to help you understand the application structure:

```bash
q "Can you analyze the Pet Store application architecture described in design_docs/architecture.md and explain the key components and their interactions in simple terms?"
```

Amazon Q will provide you with:
1. An overview of the application's layered architecture
2. Explanation of key components (API, business logic, data layers)
3. How these components interact with each other
4. The flow of data through the application

For a visual representation:

```bash
q "Can you explain the application flow diagram in design_docs/diagrams/application_flow.txt and how data moves through the Pet Store application?"
```

## Step 2: Understand the API Specification

### Using Amazon Q CLI to Understand the API

Instead of manually reviewing the API documentation, use Amazon Q CLI to help you understand the API endpoints:

```bash
q "Can you summarize the Pet Store API endpoints described in design_docs/api_spec.md and explain what each one does in simple terms?"
```

Amazon Q will provide you with:
1. A list of all available endpoints
2. The purpose of each endpoint
3. Required parameters and request formats
4. Expected responses and status codes

For more specific information about individual endpoints:

```bash
q "How do I use the POST /api/v1/pets endpoint to create a new pet? What parameters are required and what's the expected response?"
```

```bash
q "What's the difference between PUT and POST endpoints in the Pet Store API? When should I use each one?"
```

## Step 3: Explore the Data Model

### Using Amazon Q CLI to Understand the Data Model

Instead of manually reviewing the data model documentation, use Amazon Q CLI to help you understand the data structures:

```bash
q "Can you explain the Pet Store data model described in design_docs/data_model.md in simple terms? What entities exist and how are they related?"
```

Amazon Q will provide you with:
1. An overview of the data entities (like Pet)
2. The attributes and data types for each entity
3. Relationships between entities (if any)
4. Database schema information
5. Validation rules for data

For more specific information:

```bash
q "What are the required fields when creating a new Pet in the Pet Store application? Are there any validation rules I should be aware of?"
```

```bash
q "How is the database implemented in the Pet Store application? What type of database is used?"
```

## Step 4: Set Up the Local Environment

### Using Amazon Q CLI for Environment Setup

Instead of manually setting up the environment, use Amazon Q CLI to guide you through the process:

```bash
q "I need to set up the local environment for the Pet Store application in the petstore-app directory. Can you help me create a virtual environment and install the required dependencies?"
```

Amazon Q will provide you with the commands to:
1. Navigate to the petstore-app directory
2. Create a Python virtual environment
3. Activate the virtual environment
4. Install the dependencies from requirements.txt

If you encounter any issues during setup:

```bash
q "I'm getting an error when trying to install the requirements for the Pet Store application. Can you help me troubleshoot?"
```

## Step 5: Run the Application Locally

### Using Amazon Q CLI to Start the Application

Instead of manually starting the application, you can use Amazon Q CLI to help you run it as a background process:

```bash
q "I need to run the Pet Store application in the background. Can you help me start it, making sure it continues running even if I close my terminal? I'm in the petstore-app directory with the virtual environment activated."
```

Amazon Q will provide you with the commands to:
1. Start the application in the background
2. Save the process ID for later reference
3. Redirect output to a log file
4. Verify the application is running

### Verifying the Application is Running

Once Amazon Q has helped you start the application, you can verify it's running:

```bash
q "How can I verify that the Pet Store application is running correctly? I've started it in the background."
```

### Troubleshooting with Amazon Q CLI

If the application doesn't start correctly:

```bash
q "The Pet Store application isn't starting correctly. Can you help me check the logs and troubleshoot the issue?"
```

### Stopping the Application with Amazon Q CLI

When you're done testing, ask Amazon Q to help you stop the application:

```bash
q "How do I properly stop the Pet Store application that's running in the background and clean up the PID file?"
```

## Step 6: Test the API Endpoints

### Using Amazon Q CLI for API Testing

Instead of manually crafting curl commands, use Amazon Q CLI to help you test the API endpoints:

```bash
q "I need to test the Pet Store API running on http://localhost:8080. Can you help me create and run tests for all the endpoints? I want to create a pet, list all pets, get a specific pet, update a pet, and delete a pet."
```

Amazon Q will guide you through testing:
1. Checking the health endpoint
2. Creating a new pet
3. Retrieving all pets
4. Getting a specific pet by ID
5. Updating a pet
6. Creating another pet
7. Deleting a pet
8. Verifying the deletion

### Testing Specific Endpoints

You can also ask Amazon Q to help you test specific endpoints:

```bash
q "How do I create a new pet in the Pet Store API with name 'Fluffy', species 'Cat', breed 'Persian', age 2, and price 100.0?"
```

```bash
q "How do I update the pet with ID 1 to change its name to 'Fluffy Jr.' and price to 150.0?"
```

```bash
q "How do I delete a pet with ID 2 from the Pet Store API?"
```

### Analyzing API Responses

If you need help understanding the API responses:

```bash
q "I received this JSON response from the Pet Store API. Can you explain what each field means? [paste your JSON response here]"
```

### Complete Testing Workflow

For a guided end-to-end testing experience:

```bash
q "Can you guide me through a complete testing workflow for the Pet Store API? I want to test all CRUD operations in a logical sequence."
```

Amazon Q will provide you with a step-by-step testing plan and help you execute each step, explaining the expected outcomes along the way.

## Step 7: Review Deployment Requirements

### Using Amazon Q CLI to Understand Deployment Requirements

Instead of manually reviewing the deployment documentation, use Amazon Q CLI to help you understand the deployment requirements:

```bash
q "Can you analyze the deployment requirements in design_docs/deployment_requirements.md and explain what we need to consider when deploying the Pet Store application to Amazon EKS?"
```

Amazon Q will provide you with:
1. Key infrastructure requirements for EKS deployment
2. Resource specifications (CPU, memory, storage)
3. Networking configuration needs
4. Security considerations
5. Scaling parameters
6. Environment variables and configuration
7. Monitoring and logging requirements

For more specific deployment information:

```bash
q "What are the security best practices I should follow when deploying the Pet Store application to EKS?"
```

```bash
q "How should I handle environment variables and configuration when deploying the Pet Store application to Kubernetes?"
```

For a visual understanding of the deployment architecture:

```bash
q "Can you explain the deployment architecture diagram in design_docs/diagrams/deployment_arch.txt and how the components will be deployed on EKS?"
```

### Step 8: Cost Analysis with MCP Server

The AWS Cost Analysis MCP Server enhances Amazon Q's capabilities by providing cost optimization insights for your AWS deployments.

1. Install the AWS Cost Analysis MCP Server:

```bash
q "How do I install and set up the AWS Cost Analysis MCP Server from https://awslabs.github.io/mcp/servers/cost-analysis-mcp-server/"
```

2. Analyze your Terraform project for cost optimization:

```bash
q "Using the Cost Analysis MCP Server's analyze_terraform_project tool, analyze the Terraform code in deployment/terraform to identify AWS services used and potential cost optimizations"
```

The `analyze_terraform_project` tool is defined with:
```python
@mcp.tool(
    name='analyze_terraform_project',
    description='Analyze a Terraform project to identify AWS services used. This tool dynamically extracts service information from Terraform resource declarations.'
)
```

3. Review the cost analysis and implement recommended optimizations:

```bash
q "Based on the Cost Analysis MCP Server's output, what changes should I make to optimize costs in my EKS deployment?"
```


## Conclusion

In this module, you've used Amazon Q CLI to explore the Pet Store microservice application, understand its architecture, and test it locally. By leveraging AI assistance throughout the process, you've experienced how Amazon Q can accelerate understanding and working with unfamiliar applications.

Key takeaways:
- Amazon Q CLI can help you quickly understand complex application architectures
- AI assistance can generate testing commands and interpret results
- Amazon Q can troubleshoot issues and provide solutions in real-time
- Using AI for routine tasks allows you to focus on higher-level understanding

## Next Steps

Proceed to Module 2, where you'll use Amazon Q CLI to transform the application for deployment on Amazon EKS:

```bash
q "I've completed Module 1 of the workshop and understand the Pet Store application. What should I focus on in Module 2 to prepare the application for deployment to Amazon EKS?"
```
## Aligning with Project Documentation

To ensure you have a complete understanding of the project goals and structure:

```bash
q "Can you compare the README.md and WORKSHOP_PLAN.md files and explain how they relate to each other? What are the key objectives of this workshop according to these documents?"
```

This will help you understand:
1. The overall workshop objectives
2. How the modules build upon each other
3. The expected outcomes at each stage
4. How the Pet Store application will be transformed and deployed

You can also ask Amazon Q to help you understand how the actual project implementation aligns with the documentation:

```bash
q "Based on the project structure and files, how does the current state of the project align with what's described in the README and WORKSHOP_PLAN? What parts are implemented and what parts are we expected to build during the workshop?"
```
