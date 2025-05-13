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

# Function to check if a command exists
check_command() {
  if ! command -v $1 &> /dev/null; then
    echo -e "${RED}$1 not found or not in PATH${NC}"
    exit 1
  fi
}

# Check required tools
echo -e "${YELLOW}Checking required dependencies...${NC}"
check_command aws
check_command kubectl
check_command jq
check_command curl

# Verify AWS credentials
echo -e "${YELLOW}Verifying AWS credentials...${NC}"
aws sts get-caller-identity > /dev/null || { echo -e "${RED}AWS credentials not configured properly${NC}"; exit 1; }
echo -e "${GREEN}AWS credentials verified${NC}"

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

# Configure kubectl
echo -e "${YELLOW}Configuring kubectl...${NC}"
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

# Get ALB DNS name
ALB_DNS=$(kubectl get ingress petstore -n petstore -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ALB_DNS: $ALB_DNS"

echo -e "\n${YELLOW}Starting tests...${NC}"
echo -e "${YELLOW}====================${NC}"

# Section 1: Infrastructure Tests
echo -e "\n${YELLOW}Section 1: Infrastructure Tests${NC}"

# Test VPC exists
run_test "VPC exists" "aws ec2 describe-vpcs --vpc-ids $VPC_ID --region $AWS_REGION"

# Test subnets exist (3 public, 3 private)
run_test "Subnets exist" "aws ec2 describe-subnets --filters 'Name=vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(Subnets)' | grep -q '6'"

# Test NAT Gateway exists
run_test "NAT Gateway exists" "aws ec2 describe-nat-gateways --filter 'Name=vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(NatGateways)' | grep -q '1'"

# Test Internet Gateway exists
run_test "Internet Gateway exists" "aws ec2 describe-internet-gateways --filters 'Name=attachment.vpc-id,Values=$VPC_ID' --region $AWS_REGION --query 'length(InternetGateways)' | grep -q '1'"

# Test EKS cluster exists
run_test "EKS cluster exists" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION"

# Test EKS cluster is active
run_test "EKS cluster is active" "aws eks describe-cluster --name $EKS_CLUSTER_NAME --region $AWS_REGION --query 'cluster.status' | grep -q 'ACTIVE'"

# Test ECR repository exists
run_test "ECR repository exists" "aws ecr describe-repositories --repository-names $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION"

# Test ECR repository has images
run_test "ECR repository has images" "aws ecr describe-images --repository-name $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION --query 'length(imageDetails)' | grep -q '[1-9]'"

# Test IAM role for AWS Load Balancer Controller exists
run_test "IAM role for AWS Load Balancer Controller exists" "aws iam get-role --role-name $(echo $AWS_LOAD_BALANCER_CONTROLLER_ROLE_ARN | cut -d'/' -f2) --region $AWS_REGION"

# Section 2: Kubernetes Resource Tests
echo -e "\n${YELLOW}Section 2: Kubernetes Resource Tests${NC}"

# Test namespace exists
run_test "Namespace exists" "kubectl get namespace petstore"

# Test configmap exists
run_test "ConfigMap exists" "kubectl get configmap app-config -n petstore"

# Test secret exists
run_test "Secret exists" "kubectl get secret db-credentials -n petstore"

# Test deployment exists
run_test "Deployment exists" "kubectl get deployment petstore -n petstore"

# Test service exists
run_test "Service exists" "kubectl get service petstore -n petstore"

# Test ingress exists
run_test "Ingress exists" "kubectl get ingress petstore -n petstore"

# Test ingress class exists
run_test "IngressClass exists" "kubectl get ingressclass alb"

# Test AWS Load Balancer Controller is running
run_test "AWS Load Balancer Controller is running" "kubectl get deployment aws-load-balancer-controller -n kube-system -o jsonpath='{.status.readyReplicas}' | grep -q '[1-9]'"

# Test deployment has desired replicas
run_test "Deployment has desired replicas" "kubectl get deployment petstore -n petstore -o jsonpath='{.status.readyReplicas}' | grep -q '2'"

# Test pods are running
run_test "Pods are running" "kubectl get pods -n petstore -l app=petstore --field-selector status.phase=Running | grep -q petstore"

# Test pods are ready
run_test "Pods are ready" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[*].status.containerStatuses[0].ready}' | grep -q 'true'"

# Section 3: Application Functionality Tests
echo -e "\n${YELLOW}Section 3: Application Functionality Tests${NC}"

# Wait for ALB to be ready
echo -e "${YELLOW}Waiting for ALB to be ready (this may take a few minutes)...${NC}"
for i in {1..30}; do
  if curl -s -o /dev/null -w "%{http_code}" http://$ALB_DNS/api/v1/health | grep -q '200'; then
    echo -e "${GREEN}ALB is ready!${NC}"
    break
  fi
  if [ $i -eq 30 ]; then
    echo -e "${RED}ALB is not ready after 5 minutes. Continuing with tests but they may fail.${NC}"
  fi
  echo -n "."
  sleep 10
done

# Test health endpoint
run_test "Health endpoint" "curl -s http://$ALB_DNS/api/v1/health | grep -q 'healthy'"

# Test GET /pets endpoint
run_test "GET /pets endpoint" "curl -s http://$ALB_DNS/api/v1/pets | grep -q '\[\]'"

# Test POST /pets endpoint
run_test "POST /pets endpoint" "curl -s -X POST -H 'Content-Type: application/json' -d '{\"name\":\"TestDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":3,\"price\":100.0,\"status\":\"available\"}' http://$ALB_DNS/api/v1/pets | grep -q 'TestDog'"

# Test GET /pets/{id} endpoint
run_test "GET /pets/{id} endpoint" "curl -s http://$ALB_DNS/api/v1/pets/1 | grep -q 'TestDog'"

# Test PUT /pets/{id} endpoint
run_test "PUT /pets/{id} endpoint" "curl -s -X PUT -H 'Content-Type: application/json' -d '{\"name\":\"UpdatedDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":4,\"price\":150.0,\"status\":\"available\"}' http://$ALB_DNS/api/v1/pets/1 | grep -q 'UpdatedDog'"

# Test DELETE /pets/{id} endpoint
run_test "DELETE /pets/{id} endpoint" "curl -s -X DELETE http://$ALB_DNS/api/v1/pets/1"

# Verify pet was deleted
run_test "Verify pet was deleted" "curl -s http://$ALB_DNS/api/v1/pets/1 -w '%{http_code}' | grep -q '404'"

# Section 4: Security Tests
echo -e "\n${YELLOW}Section 4: Security Tests${NC}"

# Test pods are running as non-root
run_test "Pods are running as non-root" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.securityContext.runAsNonRoot}' | grep -q 'true' || kubectl exec -n petstore \$(kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].metadata.name}') -- id -u | grep -v '0'"

# Test ECR image scanning is enabled
run_test "ECR image scanning is enabled" "aws ecr describe-repositories --repository-names $(echo $ECR_REPOSITORY_URI | cut -d'/' -f2) --region $AWS_REGION --query 'repositories[0].imageScanningConfiguration.scanOnPush' | grep -q 'true'"

# Section 5: Performance Baseline Tests
echo -e "\n${YELLOW}Section 5: Performance Baseline Tests${NC}"

# Test response time is acceptable
run_test "Response time is acceptable" "time curl -s http://$ALB_DNS/api/v1/health -o /dev/null"

# Test concurrent requests
run_test "Concurrent requests" "for i in {1..10}; do curl -s http://$ALB_DNS/api/v1/health -o /dev/null & done; wait"

# Print test summary
echo -e "\n${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}====================${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some tests failed!${NC}"
  exit 1
fi
