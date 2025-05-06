# Module 2: Transforming the Application for EKS

## Overview

In this module, you will use Amazon Q CLI to transform the Pet Store microservice into a containerized application ready for deployment on Amazon EKS. You'll learn how to craft effective prompts to generate a Dockerfile, Kubernetes manifests, and Terraform code for the infrastructure.

## Learning Objectives

By the end of this module, you will be able to:
- Use Amazon Q CLI to analyze application requirements
- Generate a Dockerfile for containerizing the application
- Create Kubernetes manifests for deployment
- Develop Terraform code for EKS infrastructure
- Understand best practices for containerization and Kubernetes deployment

## Prerequisites

- Completed Module 1
- Docker installed
- Basic understanding of containers and Kubernetes
- Basic understanding of Terraform and infrastructure as code

## Step 1: Analyze the Application Requirements

Before starting the transformation, use Amazon Q CLI to analyze the application requirements based on the design documentation.

```bash
q "Analyze the design documents in the design_docs directory and summarize the key requirements for containerization and deployment to EKS"
```

Review the output to understand what needs to be considered when containerizing the application and deploying it to EKS.

## Step 2: Create a Dockerfile

Use Amazon Q CLI to generate a Dockerfile for the Pet Store application based on the deployment requirements.

```bash
q "Based on the application requirements in design_docs/deployment_requirements.md, create a Dockerfile for the Pet Store application"
```

1. Create a directory for the Docker artifacts:

```bash
mkdir -p deployment/docker
```

2. Save the generated Dockerfile to `deployment/docker/Dockerfile`.

3. Review the Dockerfile and understand:
   - Base image selection
   - Dependency installation
   - Application code copying
   - Configuration
   - Security considerations
   - Entrypoint definition

If you need to refine the Dockerfile, you can ask Amazon Q CLI for specific improvements:

```bash
q "How can I optimize this Dockerfile for security and performance?"
```

## Step 3: Create Kubernetes Manifests

Use Amazon Q CLI to generate Kubernetes manifests for deploying the Pet Store application to EKS.

```bash
q "Create Kubernetes deployment and service manifests for the Pet Store application based on the architecture described in design_docs/architecture.md and the requirements in design_docs/deployment_requirements.md"
```

1. Create a directory for Kubernetes manifests:

```bash
mkdir -p deployment/kubernetes
```

2. Save the generated manifests to appropriate files in the `deployment/kubernetes` directory.

3. Generate additional Kubernetes resources:

```bash
q "Create a Kubernetes ConfigMap and Secret manifest for the Pet Store application based on the requirements in design_docs/deployment_requirements.md"
```

```bash
q "Create a Kubernetes Ingress manifest for the Pet Store application to expose it externally"
```

```bash
q "Create a Kubernetes HorizontalPodAutoscaler manifest for the Pet Store application based on the scaling requirements in design_docs/deployment_requirements.md"
```

4. Review each manifest and understand:
   - Resource requests and limits
   - Replica configuration
   - Health checks
   - Environment variables
   - Service configuration
   - Ingress rules
   - Scaling parameters

If you need to refine any manifest, you can ask Amazon Q CLI for specific improvements:

```bash
q "How can I improve the security of my Kubernetes deployment manifest?"
```

## Step 4: Develop Terraform Code for EKS Infrastructure

Use Amazon Q CLI to generate Terraform code for provisioning an EKS cluster and the necessary infrastructure.

```bash
q "Generate Terraform code to provision an EKS cluster that meets the requirements in design_docs/deployment_requirements.md"
```

1. Create a directory for Terraform code:

```bash
mkdir -p deployment/terraform
```

2. Save the generated Terraform code to appropriate files in the `deployment/terraform` directory.

3. Generate additional Terraform resources:

```bash
q "Create Terraform code for the VPC and networking components required for the EKS cluster"
```

```bash
q "Create Terraform code for the security groups and IAM roles needed for the EKS cluster"
```

```bash
q "Create Terraform code for an AWS RDS PostgreSQL instance that can be used by the Pet Store application"
```

4. Review the Terraform code and understand:
   - VPC and networking configuration
   - EKS cluster configuration
   - Node group setup
   - Security groups and IAM roles
   - Resource tagging

If you need to refine the Terraform code, you can ask Amazon Q CLI for specific improvements:

```bash
q "How can I optimize my Terraform code for cost and security?"
```

## Step 5: Create Deployment Scripts

Use Amazon Q CLI to generate deployment scripts that will help with building and deploying the application.

```bash
q "Create a bash script that builds the Docker image, pushes it to Amazon ECR, and updates the Kubernetes manifests with the new image tag"
```

1. Create a directory for scripts:

```bash
mkdir -p deployment/scripts
```

2. Save the generated script to `deployment/scripts/build.sh`.

```bash
q "Create a bash script that applies the Terraform code and Kubernetes manifests to deploy the application to EKS"
```

3. Save the generated script to `deployment/scripts/deploy.sh`.

4. Make the scripts executable:

```bash
chmod +x deployment/scripts/build.sh
chmod +x deployment/scripts/deploy.sh
```

## Step 6: Review and Validate the Transformation

Review all the artifacts created in this module:
- Dockerfile
- Kubernetes manifests
- Terraform code
- Deployment scripts

Use Amazon Q CLI to validate the transformation:

```bash
q "Review the Dockerfile, Kubernetes manifests, and Terraform code we've created. Are there any issues or improvements that should be made?"
```

Make any suggested improvements to the artifacts.

## Conclusion

In this module, you've used Amazon Q CLI to transform the Pet Store microservice into a containerized application ready for deployment on Amazon EKS. You've created a Dockerfile, Kubernetes manifests, and Terraform code for the infrastructure.

## Next Steps

Proceed to Module 3, where you'll use Amazon Q CLI with AWS MCP Server to deploy the application to AWS.
