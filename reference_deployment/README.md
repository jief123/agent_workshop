# Pet Store Application Deployment

This directory contains all the necessary configuration files to deploy the Pet Store application on AWS EKS.

## Architecture

The Pet Store application uses:
- AWS EKS for container orchestration
- SQLite as the embedded database (no external database required)
- AWS Application Load Balancer for ingress
- AWS ECR for container image storage

## Directory Structure

- `kubernetes/`: Kubernetes manifests for deploying the application
- `terraform/`: Terraform configuration for provisioning AWS infrastructure

## Dynamic Configuration

The deployment process uses a dynamic approach where:
1. Terraform creates the infrastructure and outputs key values
2. The deployment script extracts these outputs
3. The script updates Kubernetes configuration files with the actual values
4. After deployment, the original template files are restored

This approach ensures that the configuration is always in sync with the actual infrastructure and can be deployed to different environments without manual changes.

## Deployment Instructions

To deploy the application:

```bash
./deploy.sh
```

This script will:
1. Provision the AWS infrastructure with Terraform
2. Configure kubectl to connect to the EKS cluster
3. Update Kubernetes configuration files with Terraform outputs
4. Deploy the application with Kustomize
5. Deploy the AWS Load Balancer Controller
6. Display the ingress URL when complete

## Cleanup Instructions

To clean up all AWS resources:

```bash
./cleanup.sh
```

This script will:
1. Delete all Kubernetes resources
2. Destroy all Terraform-managed infrastructure
3. Preserve all configuration files for future use
