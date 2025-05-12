# Module 2: Transforming and Deploying the Application to AWS EKS

## Overview

This combined module guides you through transforming the Pet Store microservice into a containerized application and deploying it to Amazon EKS using Amazon Q CLI. You'll use the existing DEPLOYMENT_README.md as a reference for detailed configuration when creating deployment scripts.

## Learning Objectives

- Transform the application for containerization and EKS deployment
- Create Docker and Kubernetes configurations
- Develop Terraform code for AWS infrastructure
- Use AWS Cost Analysis MCP Server to optimize deployment costs
- Generate deployment scripts based on detailed configuration documentation
- Automatically generate testing scripts to verify deployment

## Prerequisites

- Completed Module 1
- Docker installed
- AWS account with appropriate permissions
- AWS CLI, kubectl, and Terraform installed
- Basic understanding of containers, Kubernetes, and infrastructure as code
- Everything you create should be under project folder/deployment/

## Part 1: Transforming the Application

### Step 1: Review Deployment Documentation

First, review the existing DEPLOYMENT_README.md to understand the detailed configuration requirements:

```bash
q "Analyze the DEPLOYMENT_README.md in the workshop_modules directory and summarize the key configuration details for deployment scripts"
```

### Step 2: Create Dockerfile and Container Configuration

Using the specifications from the deployment documentation:

```bash
mkdir -p deployment/docker
q "Based on the Docker configuration details in DEPLOYMENT_README.md, create a Dockerfile for the Pet Store application"
```

Create an entrypoint script that follows the requirements in the documentation:

```bash
q "Create a Docker entrypoint script according to the specifications in DEPLOYMENT_README.md"
```

### Step 3: Create Kubernetes Manifests

Generate Kubernetes manifests based on the detailed configuration in the documentation:

```bash
mkdir -p deployment/kubernetes
q "Create Kubernetes manifests for the Pet Store application based on the Kubernetes Resources section in DEPLOYMENT_README.md"
```

### Step 4: Develop Terraform Infrastructure Code

Create Terraform code that matches the infrastructure specifications:

```bash
mkdir -p deployment/terraform
q "Generate Terraform code for the EKS cluster and related resources based on the Terraform Resources section in DEPLOYMENT_README.md"
```

## Part 2: Deploying to AWS

### Step 5: Set Up AWS Cost Analysis MCP Server

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

### Step 6: Generate Deployment and Testing Scripts

Create comprehensive deployment scripts based on the deployment process described in the documentation:

```bash
mkdir -p deployment/scripts
q "Create a deploy.sh script that follows the Deployment Process section in DEPLOYMENT_README.md"
```

```bash
q "Create a cleanup.sh script that follows the Cleanup Process section in DEPLOYMENT_README.md"
```

### Step 7: Deploy the Application

Deploy the application using the generated scripts:

```bash
cd deployment/scripts
./deploy.sh
```

## Part 3: Automated Testing

### Step 8: Generate Automated Testing Scripts

Have Amazon Q automatically generate testing scripts based on the documentation:

```bash
mkdir -p deployment/tests
q "Based on the DEPLOYMENT_README.md, create a comprehensive test script that verifies all aspects of the deployment including infrastructure, Kubernetes resources, and application functionality"
```

The test script should include:
- Infrastructure validation tests
- Kubernetes resource validation tests
- Application health checks
- API endpoint tests
- Security validation tests
- Performance baseline tests

Run the automated tests to verify the deployment:

```bash
cd deployment/tests
./run_tests.sh
```

## Conclusion

You've successfully transformed the Pet Store application for containerized deployment and deployed it to AWS EKS using Amazon Q CLI and the AWS Cost Analysis MCP Server. By leveraging the detailed configuration in the DEPLOYMENT_README.md and focusing on cost optimization, you've created scripts that follow best practices for deployment, security, and cost efficiency. The automated testing ensures that your deployment meets all requirements specified in the documentation.

## Next Steps

Explore advanced topics including sophisticated CI/CD pipelines, comprehensive monitoring, auto-scaling, disaster recovery, and additional security best practices.
