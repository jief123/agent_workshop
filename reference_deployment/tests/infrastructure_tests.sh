#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DEPLOYMENT_DIR="$PROJECT_ROOT/deployment"

# Test results
PASSED=0
FAILED=0
TOTAL=0

# Function to run a test
run_test() {
  local test_name=$1
  local test_command=$2
  local expected_exit_code=${3:-0}
  
  echo -e "\n${YELLOW}Running test: ${test_name}${NC}"
  TOTAL=$((TOTAL+1))
  
  eval "$test_command" > /tmp/test_output 2>&1
  local exit_code=$?
  
  if [ $exit_code -eq $expected_exit_code ]; then
    echo -e "${GREEN}✓ PASSED: ${test_name}${NC}"
    PASSED=$((PASSED+1))
  else
    echo -e "${RED}✗ FAILED: ${test_name}${NC}"
    echo -e "${RED}Expected exit code ${expected_exit_code}, got ${exit_code}${NC}"
    echo -e "${RED}Output:${NC}"
    cat /tmp/test_output
    FAILED=$((FAILED+1))
  fi
}

# Get configuration values
echo -e "${YELLOW}Getting configuration values...${NC}"
cd "$DEPLOYMENT_DIR/terraform"
EKS_CLUSTER_NAME=$(terraform output -raw cluster_name)
VPC_ID=$(terraform output -raw vpc_id)
AWS_REGION=$(terraform output -raw region 2>/dev/null || echo $(aws configure get region))
ECR_REPOSITORY_URI=$(terraform output -raw ecr_repository_url)
AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN=$(terraform output -raw aws_load_balancer_controller_role_arn)

echo "EKS_CLUSTER_NAME: $EKS_CLUSTER_NAME"
echo "VPC_ID: $VPC_ID"
echo "AWS_REGION: $AWS_REGION"
echo "ECR_REPOSITORY_URI: $ECR_REPOSITORY_URI"

echo -e "\n${YELLOW}Starting Infrastructure Tests...${NC}"
echo -e "${YELLOW}====================${NC}"

# Test VPC exists
run_test "VPC exists" "aws ec2 describe-vpcs --vpc-ids $VPC_ID --region $AWS_REGION"

# Test VPC has correct CIDR block
run_test "VPC has correct CIDR block" "aws ec2 describe-vpcs --vpc-ids $VPC_ID --region $AWS_REGION --query 'Vpcs[0].CidrBlock' | grep -q '10.0.0.0/16'"

# Test subnets exist (3 public, 3 private)
run_test "Subnets exist" "aws ec2 describe-subnets --filters 'Name=vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(Subnets)' | grep -q '6'"

# Test public subnets have correct CIDR blocks
run_test "Public subnets have correct CIDR blocks" "aws ec2 describe-subnets --filters 'Name=vpc-id,Values=$VPC_ID' 'Name=tag:Name,Values=*public*' --region $AWS_REGION --query 'Subnets[].CidrBlock' | grep -q '10.0.10[1-3].0/24'"

# Test private subnets have correct CIDR blocks
run_test "Private subnets have correct CIDR blocks" "aws ec2 describe-subnets --filters 'Name=vpc-id,Values=$VPC_ID' 'Name=tag:Name,Values=*private*' --region $AWS_REGION --query 'Subnets[].CidrBlock' | grep -q '10.0.[1-3].0/24'"

# Test NAT Gateway exists
run_test "NAT Gateway exists" "aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(NatGateways)' | grep -q '[1-3]'"

# Test Internet Gateway exists
run_test "Internet Gateway exists" "aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(InternetGateways)' | grep -q '1'"

# Test EKS cluster exists
run_test "EKS cluster exists" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION"

# Test EKS cluster is active
run_test "EKS cluster is active" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.status' | grep -q 'ACTIVE'"

# Test EKS cluster version
run_test "EKS cluster has correct version" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.version' | grep -q '1.28'"

# Test EKS cluster endpoint access
run_test "EKS cluster has public endpoint access" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.resourcesVpcConfig.endpointPublicAccess' | grep -q 'true'"

# Test EKS node group exists
run_test "EKS node group exists" "aws eks list-nodegroups --cluster-name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'length(nodegroups)' | grep -q '[1-9]'"

# Test EKS node group instance type
run_test "EKS node group has correct instance type" "aws eks describe-nodegroup --cluster-name $EKS_CLUSTER_NAME --nodegroup-name \$(aws eks list-nodegroups --cluster-name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'nodegroups[0]' --output text) --region $AWS_REGION --query 'nodegroup.instanceTypes[0]' | grep -q 't3.small'"

# Test EKS node group scaling configuration
run_test "EKS node group has correct scaling configuration" "aws eks describe-nodegroup --cluster-name $EKS_CLUSTER_NAME --nodegroup-name \$(aws eks list-nodegroups --cluster-name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'nodegroups[0]' --output text) --region $AWS_REGION --query 'nodegroup.scalingConfig.minSize' | grep -q '2'"

# Test ECR repository exists
run_test "ECR repository exists" "aws ecr describe-repositories --repository-names $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION"

# Test ECR repository has images
run_test "ECR repository has images" "aws ecr describe-images --repository-name $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION --query 'length(imageDetails)' | grep -q '[1-9]'"

# Test ECR image scanning is enabled
run_test "ECR image scanning is enabled" "aws ecr describe-repositories --repository-names $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION --query 'repositories[0].imageScanningConfiguration.scanOnPush' | grep -q 'true'"

# Test IAM role for AWS Load Balancer Controller exists
run_test "IAM role for AWS Load Balancer Controller exists" "aws iam get-role --role-name $(echo $AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN | cut -d'/' -f2) --region $AWS_REGION"

# Test IAM role has correct trust relationship
run_test "IAM role has correct trust relationship" "aws iam get-role --role-name $(echo $AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN | cut -d'/' -f2) --region $AWS_REGION --query 'Role.AssumeRolePolicyDocument' | grep -q 'oidc.eks'"

# Test IAM role has required policies
run_test "IAM role has required policies" "aws iam list-attached-role-policies --role-name $(echo $AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN | cut -d'/' -f2) --region $AWS_REGION --query 'length(AttachedPolicies)' | grep -q '[1-9]'"

# Print test summary
echo -e "\n${YELLOW}Infrastructure Test Summary${NC}"
echo -e "${YELLOW}====================${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All infrastructure tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some infrastructure tests failed!${NC}"
  exit 1
fi
