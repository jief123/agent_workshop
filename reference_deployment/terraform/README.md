# Terraform Configuration for Pet Store Infrastructure

This directory contains the Terraform configuration for provisioning the AWS infrastructure required for the Pet Store application.

## Infrastructure Components

- **VPC**: Virtual Private Cloud with public and private subnets
- **EKS Cluster**: Kubernetes cluster for running the application
- **ECR Repository**: Container registry for storing application images
- **IAM Roles and Policies**: Required permissions for EKS and ECR

## Database

The application uses SQLite as an embedded database, so no external database resources are provisioned.

## Files

- `main.tf`: Main Terraform configuration
- `variables.tf`: Variable definitions
- `outputs.tf`: Output values
- `terraform.tfvars`: Variable values (not committed to version control)

## Usage

```bash
# Initialize Terraform
terraform init

# Preview changes
terraform plan

# Apply changes
terraform apply

# Configure kubectl
aws eks update-kubeconfig --region us-east-1 --name petstore-eks
```
