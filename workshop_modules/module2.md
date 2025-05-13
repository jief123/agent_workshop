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
- Refactor the application to use Amazon RDS for data consistency

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
q "Based on the Docker configuration details in DEPLOYMENT_README.md, create a Dockerfile for the Pet Store application"
```

Create an entrypoint script that follows the requirements in the documentation:

```bash
q "Create a Docker entrypoint script according to the specifications in DEPLOYMENT_README.md"
```

Test Docker image locally
```bash
q "do local test for docker setup"
```

Cleanup local test enviroment
```bash
q "Please clean up local test enviroment"
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
q "Read DEPLOYMENT_README.md again, and Generate Terraform code for the EKS cluster and related resources based on DEPLOYMENT_README.md, take care about issues and notices"
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
q"run deployment/scripts/deploy.sh to deploy it"
```

## Part 3: Automated Testing

### Step 8: Generate Automated Testing Scripts

Have Amazon Q automatically generate testing scripts based on the documentation:

```bash
mkdir -p deployment/tests
q "Based on the DEPLOYMENT_README.md, create a test script that verifies application functionality"
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

## Part 4: Refactoring for Data Consistency with Amazon RDS

After deploying and testing the application, you may notice data consistency issues between pods. This is because each pod uses its own SQLite database, leading to different data in each pod. Let's refactor the application to use Amazon RDS PostgreSQL for a shared database experience.

### Step 9: Identify Data Consistency Issues

Run the data consistency test to identify the problem:

```bash
cd deployment/tests
./test_existing_deployment_with_consistency.sh
```

This test will show that data created in one pod is not visible in other pods, indicating that each pod has its own isolated database.

### Step 10: Create a Refactoring Plan

Create a comprehensive plan for migrating from SQLite to Amazon RDS:

```bash
q "Create a detailed implementation plan for migrating the Pet Store application from SQLite to Amazon RDS PostgreSQL to solve data consistency issues between pods"
```

Save this plan as a reference document:

```bash
q "Save the migration plan to deployment/refactortords.md"
```

### Step 11: Provision Amazon RDS PostgreSQL Instance

Follow the plan to create the necessary AWS resources:

```bash
q "Help me execute Phase 1 of the refactortords.md plan to provision an Amazon RDS PostgreSQL instance"
```

### Step 12: Update Kubernetes Configuration

Update the Kubernetes secret to use the RDS connection string:

```bash
q "Update the Kubernetes secret to use the RDS connection string as described in Phase 2 of refactortords.md"
```

### Step 13: Migrate Data

Create and run the data migration script:

```bash
q "Create and execute the data migration script as described in Phase 3 of refactortords.md"
```

### Step 14: Update Deployment and Verify

Update the deployment to use RDS and verify the changes:

```bash
q "Execute Phase 4 of refactortords.md to update the deployment and verify database connectivity"
```

### Step 15: Set Up Monitoring and Maintenance

Configure monitoring and maintenance for the RDS instance:

```bash
q "Set up CloudWatch alarms and automated backups for the RDS instance as described in Phase 5 of refactortords.md"
```

### Step 16: Verify Data Consistency

Run the data consistency test again to verify that the issue is resolved:

```bash
cd deployment/tests
./test_existing_deployment_with_consistency.sh
```

This time, the test should pass, showing that data is consistent across all pods because they're all using the same shared RDS database.

## Conclusion

You've successfully transformed the Pet Store application for containerized deployment and deployed it to AWS EKS using Amazon Q CLI and the AWS Cost Analysis MCP Server. By leveraging the detailed configuration in the DEPLOYMENT_README.md and focusing on cost optimization, you've created scripts that follow best practices for deployment, security, and cost efficiency. 

Additionally, you've refactored the application to use Amazon RDS PostgreSQL instead of SQLite, solving the data consistency issues between pods. This demonstrates how to identify and resolve real-world architectural challenges in cloud deployments.

The automated testing ensures that your deployment meets all requirements specified in the documentation and that data remains consistent across all application instances.

## Next Steps

Explore advanced topics including sophisticated CI/CD pipelines, comprehensive monitoring, auto-scaling, disaster recovery, and additional security best practices.
