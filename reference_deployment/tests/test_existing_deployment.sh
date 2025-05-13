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
    cat /tmp/test_output
    PASSED=$((PASSED+1))
  else
    echo -e "${RED}✗ FAILED: ${test_name}${NC}"
    echo -e "${RED}Expected exit code ${expected_exit_code}, got ${exit_code}${NC}"
    echo -e "${RED}Output:${NC}"
    cat /tmp/test_output
    FAILED=$((FAILED+1))
  fi
}

echo -e "${YELLOW}Testing Existing Pet Store Deployment${NC}"
echo -e "${YELLOW}==================================${NC}"

# Section 1: Verify Kubernetes Resources
echo -e "\n${YELLOW}Section 1: Verifying Kubernetes Resources${NC}"

# Test namespace exists
run_test "Namespace exists" "kubectl get namespace petstore -o jsonpath='{.metadata.name}'"

# Test deployment exists and has correct replicas
run_test "Deployment exists with 2 replicas" "kubectl get deployment petstore -n petstore -o jsonpath='{.status.readyReplicas}' | grep '2'"

# Test pods are running
run_test "Pods are running" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[*].status.phase}' | grep 'Running'"

# Test service exists
run_test "Service exists" "kubectl get service petstore -n petstore -o jsonpath='{.metadata.name}'"

# Test ingress exists
run_test "Ingress exists" "kubectl get ingress petstore -n petstore -o jsonpath='{.metadata.name}'"

# Test ingress has ALB address
run_test "Ingress has ALB address" "kubectl get ingress petstore -n petstore -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' | grep 'elb.amazonaws.com'"

# Test AWS Load Balancer Controller is running
run_test "AWS Load Balancer Controller is running" "kubectl get deployment aws-load-balancer-controller -n kube-system -o jsonpath='{.status.readyReplicas}' | grep '[1-9]'"

# Section 2: Test Application Functionality via Port-Forward
echo -e "\n${YELLOW}Section 2: Testing Application Functionality via Port-Forward${NC}"

# Get a pod name
POD_NAME=$(kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].metadata.name}')
echo -e "${YELLOW}Using pod: ${POD_NAME}${NC}"

# Start port-forward in the background
kubectl port-forward -n petstore $POD_NAME 8080:8080 &
PORT_FORWARD_PID=$!

# Wait for port-forward to establish
echo -e "${YELLOW}Waiting for port-forward to establish...${NC}"
sleep 5

# Test health endpoint
run_test "Health endpoint" "curl -s http://localhost:8080/api/v1/health | grep 'healthy'"

# Test GET /pets endpoint
run_test "GET /pets endpoint" "curl -s http://localhost:8080/api/v1/pets"

# Test POST /pets endpoint
run_test "POST /pets endpoint" "curl -s -X POST -H 'Content-Type: application/json' -d '{\"name\":\"TestDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":3,\"price\":100.0,\"status\":\"available\"}' http://localhost:8080/api/v1/pets | grep 'TestDog'"

# Get the ID of the first pet
PET_ID=$(curl -s http://localhost:8080/api/v1/pets | grep -o '\"id\":[0-9]*' | head -1 | cut -d':' -f2)
echo -e "${YELLOW}Testing with PET_ID: ${PET_ID}${NC}"

# Test GET /pets/{id} endpoint
run_test "GET /pets/{id} endpoint" "curl -s http://localhost:8080/api/v1/pets/$PET_ID | grep 'TestDog'"

# Test PUT /pets/{id} endpoint
run_test "PUT /pets/{id} endpoint" "curl -s -X PUT -H 'Content-Type: application/json' -d '{\"name\":\"UpdatedDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":4,\"price\":150.0,\"status\":\"available\"}' http://localhost:8080/api/v1/pets/$PET_ID | grep 'UpdatedDog'"

# Test DELETE /pets/{id} endpoint
run_test "DELETE /pets/{id} endpoint" "curl -s -X DELETE http://localhost:8080/api/v1/pets/$PET_ID"

# Verify pet was deleted
run_test "Verify pet was deleted" "curl -s -o /dev/null -w '%{http_code}' http://localhost:8080/api/v1/pets/$PET_ID | grep '404'"

# Kill port-forward process
kill $PORT_FORWARD_PID

# Section 3: Verify ALB Configuration (without testing endpoints)
echo -e "\n${YELLOW}Section 3: Verifying ALB Configuration${NC}"

# Get ALB DNS name
ALB_DNS=$(kubectl get ingress petstore -n petstore -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo -e "${YELLOW}ALB DNS: ${ALB_DNS}${NC}"

# Test ALB exists in AWS
run_test "ALB exists in AWS" "aws elbv2 describe-load-balancers --region $(aws configure get region) --query \"LoadBalancers[?contains(DNSName, '$(echo $ALB_DNS | cut -d'.' -f1)')].LoadBalancerArn\" --output text"

# Test ALB has target groups
run_test "ALB has target groups" "aws elbv2 describe-target-groups --region $(aws configure get region) --query \"TargetGroups[?contains(TargetGroupArn, 'petstore')].TargetGroupArn\" --output text"

# Test ALB has listeners
run_test "ALB has listeners" "aws elbv2 describe-listeners --region $(aws configure get region) --load-balancer-arn \$(aws elbv2 describe-load-balancers --region $(aws configure get region) --query \"LoadBalancers[?contains(DNSName, '$(echo $ALB_DNS | cut -d'.' -f1)')].LoadBalancerArn\" --output text) --query \"Listeners[0].ListenerArn\" --output text"

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
