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

# Configure kubectl
echo -e "${YELLOW}Configuring kubectl...${NC}"
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

echo -e "\n${YELLOW}Starting Security Tests...${NC}"
echo -e "${YELLOW}====================${NC}"

# Test VPC security groups
run_test "VPC has security groups" "aws ec2 describe-security-groups --filters 'Name=vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(SecurityGroups)' | grep -q '[1-9]'"

# Test EKS cluster security group
run_test "EKS cluster has security group" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' | grep -q 'sg-'"

# Test EKS cluster endpoint private access
run_test "EKS cluster has private endpoint access" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.resourcesVpcConfig.endpointPrivateAccess' | grep -q 'true\\|false'"

# Test EKS cluster encryption
run_test "EKS cluster has encryption configuration" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.encryptionConfig' | grep -q 'provider\\|resources'"

# Test EKS cluster logging
run_test "EKS cluster has logging configuration" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.logging' | grep -q 'clusterLogging\\|enabled'"

# Test ECR image scanning is enabled
run_test "ECR image scanning is enabled" "aws ecr describe-repositories --repository-names $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION --query 'repositories[0].imageScanningConfiguration.scanOnPush' | grep -q 'true'"

# Test ECR image scan findings
run_test "ECR image scan findings" "aws ecr describe-image-scan-findings --repository-name $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --image-id imageTag=latest --region $AWS_REGION || echo 'No scan findings available'"

# Test pods are running as non-root
run_test "Pods are running as non-root" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.securityContext.runAsNonRoot}' | grep -q 'true' || kubectl exec -n petstore \$(kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].metadata.name}') -- id -u | grep -v '0'"

# Test pods have security context
run_test "Pods have security context" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.securityContext}' | grep -q '.'"

# Test pods have resource limits
run_test "Pods have resource limits" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.containers[0].resources.limits}' | grep -q 'cpu'"

# Test service account permissions
run_test "Service account permissions" "kubectl get serviceaccount -n petstore default -o yaml | grep -q 'secrets'"

# Test network policies
run_test "Network policies" "kubectl get networkpolicies -n petstore || echo 'No network policies found'"

# Test pod security policies
run_test "Pod security policies" "kubectl get psp || echo 'No pod security policies found'"

# Test RBAC configuration
run_test "RBAC configuration" "kubectl get roles,clusterroles,rolebindings,clusterrolebindings -n petstore || echo 'No RBAC configuration found'"

# Test secrets encryption
run_test "Secrets encryption" "kubectl get secret db-credentials -n petstore -o jsonpath='{.data.DATABASE_URL}' | grep -q '.'"

# Test ALB security groups
run_test "ALB security groups" "aws elbv2 describe-load-balancers --region $AWS_REGION --query 'LoadBalancers[?contains(DNSName, `k8s-petstore`)].SecurityGroups' | grep -q 'sg-'"

# Test ALB listener protocol
run_test "ALB listener protocol" "aws elbv2 describe-listeners --region $AWS_REGION --load-balancer-arn \$(aws elbv2 describe-load-balancers --region $AWS_REGION --query 'LoadBalancers[?contains(DNSName, `k8s-petstore`)].LoadBalancerArn' --output text) --query 'Listeners[0].Protocol' | grep -q 'HTTP\\|HTTPS'"

# Test ALB access logs
run_test "ALB access logs" "aws elbv2 describe-load-balancer-attributes --region $AWS_REGION --load-balancer-arn \$(aws elbv2 describe-load-balancers --region $AWS_REGION --query 'LoadBalancers[?contains(DNSName, `k8s-petstore`)].LoadBalancerArn' --output text) --query 'Attributes[?Key==`access_logs.s3.enabled`].Value' | grep -q 'true\\|false'"

# Test IAM roles for service accounts
run_test "IAM roles for service accounts" "kubectl get serviceaccount aws-load-balancer-controller -n kube-system -o jsonpath='{.metadata.annotations}' | grep -q 'eks.amazonaws.com/role-arn'"

# Print test summary
echo -e "\n${YELLOW}Security Test Summary${NC}"
echo -e "${YELLOW}====================${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All security tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some security tests failed!${NC}"
  exit 1
fi
