#!/bin/bash
# Script to clean up AWS resources while preserving configuration files

echo "Starting AWS resource cleanup..."

# Step 1: Delete Kubernetes resources
echo "Deleting Kubernetes resources..."

# Delete the ingress first to ensure ALB is properly deleted
echo "Deleting ingress..."
kubectl delete ingress -n petstore petstore-ingress

# Delete the AWS Load Balancer Controller
echo "Uninstalling AWS Load Balancer Controller..."
helm uninstall aws-load-balancer-controller -n kube-system

# Delete IngressClass
echo "Deleting IngressClass..."
kubectl delete ingressclass alb

# Delete all other Kubernetes resources
echo "Deleting petstore namespace..."
kubectl delete namespace petstore

# Wait for resources to be deleted
echo "Waiting for Kubernetes resources to be fully deleted..."
sleep 30

# Step 2: Clean up Docker images from ECR
echo "Cleaning up Docker images from ECR..."
cd /home/ubuntu/agent_workshop/deployment/terraform
ECR_REPO=$(terraform output -raw ecr_repository_url)
REGION=$(terraform output -raw region)

# Delete all images in the repository
echo "Deleting all images from ECR repository..."
aws ecr batch-delete-image --repository-name petstore --image-ids "$(aws ecr list-images --repository-name petstore --query 'imageIds[*]' --output json)" --region $REGION || true

# Step 0: Delete EKS-created security groups that might block VPC deletion
echo "Checking for EKS-created security groups..."
VPC_ID=$(cd /home/ubuntu/agent_workshop/deployment/terraform && terraform output -raw vpc_id)
if [ ! -z "$VPC_ID" ]; then
  echo "Found VPC ID: $VPC_ID"
  # Find and delete security groups with EKS tags
  EKS_SG_IDS=$(aws ec2 describe-security-groups --filters "Name=vpc-id,Values=$VPC_ID" "Name=tag-key,Values=elbv2.k8s.aws/cluster" --query "SecurityGroups[*].GroupId" --output text)
  
  if [ ! -z "$EKS_SG_IDS" ]; then
    echo "Found EKS security groups to delete: $EKS_SG_IDS"
    for SG_ID in $EKS_SG_IDS; do
      echo "Deleting security group $SG_ID..."
      aws ec2 delete-security-group --group-id $SG_ID
    done
  else
    echo "No EKS security groups found."
  fi
else
  echo "Could not determine VPC ID, skipping security group cleanup."
fi

# Step 3: Destroy Terraform-managed infrastructure
echo "Destroying Terraform-managed infrastructure..."
terraform destroy -auto-approve

# Step 4: Clean up IAM policy manually since Terraform might not delete it
echo "Checking if IAM policy needs to be deleted manually..."
POLICY_ARN=$(aws iam list-policies --query "Policies[?PolicyName=='AWSLoadBalancerControllerIAMPolicy'].Arn" --output text)

if [ ! -z "$POLICY_ARN" ]; then
  echo "Deleting IAM policy AWSLoadBalancerControllerIAMPolicy..."
  # First detach the policy from any roles
  for role in $(aws iam list-entities-for-policy --policy-arn $POLICY_ARN --query "PolicyRoles[].RoleName" --output text); do
    echo "Detaching policy from role $role..."
    aws iam detach-role-policy --role-name $role --policy-arn $POLICY_ARN
  done
  
  # Then delete the policy
  aws iam delete-policy --policy-arn $POLICY_ARN
  echo "IAM policy deleted."
else
  echo "IAM policy not found or already deleted."
fi

echo "Cleanup complete. Configuration files have been preserved."
echo "You can now deploy to a new environment using the existing configuration files."
