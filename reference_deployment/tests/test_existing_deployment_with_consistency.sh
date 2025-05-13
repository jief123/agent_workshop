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

# Function to cleanup port-forward processes
cleanup() {
  echo -e "\n${YELLOW}Cleaning up port-forward processes...${NC}"
  if [ ! -z "$PORT_FORWARD_PID" ]; then
    kill $PORT_FORWARD_PID 2>/dev/null || true
  fi
  if [ ! -z "$PORT_FORWARD_PID_1" ]; then
    kill $PORT_FORWARD_PID_1 2>/dev/null || true
  fi
  if [ ! -z "$PORT_FORWARD_PID_2" ]; then
    kill $PORT_FORWARD_PID_2 2>/dev/null || true
  fi
  # Kill any other port-forward processes
  pkill -f "kubectl port-forward.*petstore" || true
}

# Set up trap to ensure cleanup on exit
trap cleanup EXIT

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

# Make sure no existing port-forward is running
cleanup

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
run_test "GET /pets/{id} endpoint" "curl -s http://localhost:8080/api/v1/pets/$PET_ID"

# Test PUT /pets/{id} endpoint
run_test "PUT /pets/{id} endpoint" "curl -s -X PUT -H 'Content-Type: application/json' -d '{\"name\":\"UpdatedDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":4,\"price\":150.0,\"status\":\"available\"}' http://localhost:8080/api/v1/pets/$PET_ID | grep 'UpdatedDog'"

# Cleanup port-forward before proceeding
kill $PORT_FORWARD_PID
unset PORT_FORWARD_PID

# Section 3: Verify ALB Configuration (without testing endpoints)
echo -e "\n${YELLOW}Section 3: Verifying ALB Configuration${NC}"

# Get ALB DNS name
ALB_DNS=$(kubectl get ingress petstore -n petstore -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo -e "${YELLOW}ALB DNS: ${ALB_DNS}${NC}"

# Extract ALB name from DNS
ALB_NAME=$(echo $ALB_DNS | cut -d'.' -f1)

# Test ALB exists in AWS
run_test "ALB exists in AWS" "aws elbv2 describe-load-balancers --region $(aws configure get region) --query \"LoadBalancers[?contains(DNSName, '$ALB_NAME')].LoadBalancerArn\" --output text"

# Test ALB has target groups
run_test "ALB has target groups" "aws elbv2 describe-target-groups --region $(aws configure get region) --query \"TargetGroups[?contains(TargetGroupName, 'petstore')].TargetGroupArn\" --output text || echo 'No target groups with petstore in name'"

# Test ALB has listeners
run_test "ALB has listeners" "aws elbv2 describe-listeners --region $(aws configure get region) --load-balancer-arn \$(aws elbv2 describe-load-balancers --region $(aws configure get region) --query \"LoadBalancers[?contains(DNSName, '$ALB_NAME')].LoadBalancerArn\" --output text) --query \"Listeners[0].ListenerArn\" --output text"

# Section 4: Data Consistency Test
echo -e "\n${YELLOW}Section 4: Testing Data Consistency Between Pods${NC}"

# Get pod names
PODS=($(kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[*].metadata.name}'))
echo -e "${YELLOW}Found ${#PODS[@]} pods:${NC}"
for POD in "${PODS[@]}"; do
  echo "- $POD"
done

if [ ${#PODS[@]} -lt 2 ]; then
  echo -e "${RED}Need at least 2 pods to test data consistency${NC}"
  FAILED=$((FAILED+1))
else
  # Start port-forward for first pod on port 8081
  echo -e "\n${YELLOW}Setting up port-forward for pod 1: ${PODS[0]}${NC}"
  kubectl port-forward -n petstore ${PODS[0]} 8081:8080 &
  PORT_FORWARD_PID_1=$!
  
  # Start port-forward for second pod on port 8082
  echo -e "${YELLOW}Setting up port-forward for pod 2: ${PODS[1]}${NC}"
  kubectl port-forward -n petstore ${PODS[1]} 8082:8080 &
  PORT_FORWARD_PID_2=$!
  
  # Wait for port-forwards to establish
  echo -e "${YELLOW}Waiting for port-forwards to establish...${NC}"
  sleep 5
  
  # Test 1: Check initial data in both pods
  echo -e "\n${YELLOW}Test 1: Checking initial data in both pods${NC}"
  POD1_DATA=$(curl -s http://localhost:8081/api/v1/pets)
  POD2_DATA=$(curl -s http://localhost:8082/api/v1/pets)
  
  echo -e "${YELLOW}Pod 1 data:${NC}"
  echo "$POD1_DATA"
  echo -e "${YELLOW}Pod 2 data:${NC}"
  echo "$POD2_DATA"
  
  # Test 2: Create data in pod 1 and check if it appears in pod 2
  echo -e "\n${YELLOW}Test 2: Creating data in pod 1 and checking if it appears in pod 2${NC}"
  CREATE_RESULT=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name":"ConsistencyTest","species":"Dog","breed":"TestBreed","age":5,"price":200.0,"status":"available"}' http://localhost:8081/api/v1/pets)
  echo -e "${YELLOW}Created in pod 1:${NC}"
  echo "$CREATE_RESULT"
  
  # Extract created pet ID
  CONSISTENCY_PET_ID=$(echo $CREATE_RESULT | grep -o '"id":[0-9]*' | cut -d':' -f2)
  echo -e "${YELLOW}Created pet ID: $CONSISTENCY_PET_ID${NC}"
  
  # Wait a moment for potential sync
  sleep 5
  
  # Check if pet exists in pod 2
  echo -e "${YELLOW}Checking if pet exists in pod 2:${NC}"
  POD2_CHECK=$(curl -s http://localhost:8082/api/v1/pets/$CONSISTENCY_PET_ID)
  echo "$POD2_CHECK"
  
  # Test 3: Create data in pod 2 and check if it appears in pod 1
  echo -e "\n${YELLOW}Test 3: Creating data in pod 2 and checking if it appears in pod 1${NC}"
  CREATE_RESULT2=$(curl -s -X POST -H "Content-Type: application/json" -d '{"name":"ConsistencyTest2","species":"Cat","breed":"TestBreed","age":3,"price":150.0,"status":"available"}' http://localhost:8082/api/v1/pets)
  echo -e "${YELLOW}Created in pod 2:${NC}"
  echo "$CREATE_RESULT2"
  
  # Extract created pet ID
  CONSISTENCY_PET_ID2=$(echo $CREATE_RESULT2 | grep -o '"id":[0-9]*' | cut -d':' -f2)
  echo -e "${YELLOW}Created pet ID: $CONSISTENCY_PET_ID2${NC}"
  
  # Wait a moment for potential sync
  sleep 5
  
  # Check if pet exists in pod 1
  echo -e "${YELLOW}Checking if pet exists in pod 1:${NC}"
  POD1_CHECK=$(curl -s http://localhost:8081/api/v1/pets/$CONSISTENCY_PET_ID2)
  echo "$POD1_CHECK"
  
  # Test 4: Final check of all data in both pods
  echo -e "\n${YELLOW}Test 4: Final check of all data in both pods${NC}"
  FINAL_POD1_DATA=$(curl -s http://localhost:8081/api/v1/pets)
  FINAL_POD2_DATA=$(curl -s http://localhost:8082/api/v1/pets)
  
  echo -e "${YELLOW}Final pod 1 data:${NC}"
  echo "$FINAL_POD1_DATA"
  echo -e "${YELLOW}Final pod 2 data:${NC}"
  echo "$FINAL_POD2_DATA"
  
  # Check for data consistency issues
  if [[ "$FINAL_POD1_DATA" == "$FINAL_POD2_DATA" ]]; then
    echo -e "${GREEN}✓ Data is consistent between pods${NC}"
    PASSED=$((PASSED+1))
  else
    echo -e "${RED}✗ Data inconsistency detected between pods${NC}"
    echo -e "${RED}This is a bug in the application: each pod is using its own SQLite database instance${NC}"
    FAILED=$((FAILED+1))
  fi
  
  # Cleanup port-forwards
  kill $PORT_FORWARD_PID_1 $PORT_FORWARD_PID_2
  unset PORT_FORWARD_PID_1 PORT_FORWARD_PID_2
fi

# Print test summary
echo -e "\n${YELLOW}Test Summary${NC}"
echo -e "${YELLOW}====================${NC}"
echo -e "Total tests: $((TOTAL+1))" # +1 for data consistency test
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some tests failed!${NC}"
  
  # If data inconsistency was detected, provide solution recommendations
  if [[ "$FINAL_POD1_DATA" != "$FINAL_POD2_DATA" ]]; then
    echo -e "\n${YELLOW}Data Consistency Issue Detected${NC}"
    echo -e "${RED}Problem: Each pod is using its own SQLite database instance, leading to data inconsistency.${NC}"
    echo -e "${GREEN}Recommended Solutions:${NC}"
    echo -e "  1. Use a shared database service like Amazon RDS instead of SQLite"
    echo -e "  2. Configure a persistent volume (PV) and persistent volume claim (PVC) to share the database file"
    echo -e "  3. Use a StatefulSet instead of a Deployment for stateful applications"
    echo -e "  4. Implement a data synchronization mechanism between pods"
    echo -e "\n${YELLOW}Example RDS Configuration:${NC}"
    echo -e "  - Create an Amazon RDS PostgreSQL instance"
    echo -e "  - Update the application's DATABASE_URL environment variable to point to the RDS instance"
    echo -e "  - Ensure the security group allows connections from the EKS cluster"
  fi
  
  exit 1
fi
