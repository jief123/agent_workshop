# Module 3: Deploying to AWS with Q CLI + MCP Server

## Overview

In this module, you will use Amazon Q CLI with AWS MCP (Model Context Provider) Server to deploy the Pet Store application to AWS. You'll learn how MCP Server enhances Amazon Q's capabilities by providing additional context about your AWS environment.

## Learning Objectives

By the end of this module, you will be able to:
- Set up AWS MCP Server for enhanced AI assistance
- Use Amazon Q CLI with MCP Server to validate infrastructure code
- Identify and fix security issues in your deployment
- Optimize resource configurations
- Deploy the application to AWS EKS
- Verify and test the deployment

## Prerequisites

- Completed Module 2
- AWS account with appropriate permissions
- AWS CLI configured
- kubectl installed and configured
- Terraform installed

## Step 1: Understanding AWS MCP Server

AWS MCP (Model Context Provider) Server enhances Amazon Q's capabilities by providing additional context about your AWS environment. This allows Amazon Q to provide more specific and relevant assistance for your AWS deployments.

Use Amazon Q CLI to learn more about MCP Server:

```bash
q "Explain what AWS MCP Server is and how it enhances Amazon Q CLI for AWS deployments"
```

## Step 2: Set Up AWS MCP Server

Follow the instructions provided by Amazon Q CLI to set up MCP Server:

```bash
q "How do I set up AWS MCP Server to work with Amazon Q CLI?"
```

Once MCP Server is set up, Amazon Q CLI will have access to additional context about your AWS environment, allowing it to provide more specific assistance.

## Step 3: Validate Infrastructure Code

Use Amazon Q CLI with MCP Server to validate your infrastructure code and identify potential issues:

```bash
q "Validate the Terraform code in the deployment/terraform directory and identify any issues or best practices that aren't being followed"
```

Review the feedback and make any necessary changes to the Terraform code.

For security scanning, use:

```bash
q "Perform a security scan of the Terraform code and Kubernetes manifests. Identify any security issues and suggest fixes"
```

Implement the suggested fixes to address any security issues.

## Step 4: Optimize Resource Configurations

Use Amazon Q CLI with MCP Server to optimize your resource configurations for cost and performance:

```bash
q "Analyze the resource configurations in the Terraform code and Kubernetes manifests. Suggest optimizations for cost and performance based on AWS best practices"
```

Review the suggestions and implement any optimizations that make sense for your deployment.

## Step 5: Prepare for Deployment

Before deploying, use Amazon Q CLI to help prepare your environment:

```bash
q "What steps should I take to prepare my AWS environment for deploying the Pet Store application to EKS?"
```

Follow the steps provided by Amazon Q CLI to prepare your environment.

## Step 6: Deploy the Application

Use Amazon Q CLI to guide you through the deployment process:

```bash
q "Guide me through the process of deploying the Pet Store application to EKS using the Terraform code and Kubernetes manifests we've created"
```

Follow the step-by-step instructions provided by Amazon Q CLI to deploy the application.

If you encounter any issues during deployment, you can ask Amazon Q CLI for help:

```bash
q "I'm getting an error when applying the Terraform code. The error is: [paste error message]. How can I fix this?"
```

## Step 7: Verify and Test the Deployment

After deploying the application, use Amazon Q CLI to help you verify that it's running correctly:

```bash
q "How can I verify that the Pet Store application has been deployed successfully to EKS?"
```

Follow the instructions to verify the deployment.

For testing the API endpoints, ask:

```bash
q "Generate commands to test all the API endpoints of the deployed Pet Store application"
```

Use the generated commands to test the application.

## Step 8: Set Up Monitoring

Use Amazon Q CLI to help you set up monitoring for your application:

```bash
q "How do I set up CloudWatch Container Insights for my EKS cluster to monitor the Pet Store application?"
```

Follow the instructions to set up monitoring.

For creating CloudWatch dashboards:

```bash
q "Generate CloudFormation code for a CloudWatch dashboard to monitor the Pet Store application on EKS"
```

Deploy the generated dashboard to monitor your application.

## Step 9: Implement Continuous Deployment

Use Amazon Q CLI to help you set up continuous deployment:

```bash
q "How can I implement a CI/CD pipeline for the Pet Store application using AWS services?"
```

Follow the instructions to set up continuous deployment for your application.

## Conclusion

In this module, you've used Amazon Q CLI with AWS MCP Server to deploy the Pet Store application to AWS EKS. You've learned how MCP Server enhances Amazon Q's capabilities by providing additional context about your AWS environment, allowing for more specific and relevant assistance.

## Next Steps

Explore the advanced topics in the workshop to further enhance your Pet Store application deployment:
- Implementing more sophisticated CI/CD pipelines
- Adding more comprehensive monitoring and observability
- Configuring auto-scaling
- Setting up disaster recovery
- Implementing additional security best practices
