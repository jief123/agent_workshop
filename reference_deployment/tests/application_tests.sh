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
AWS_REGION=$(terraform output -raw region 2>/dev/null || echo $(aws configure get region))

# Configure kubectl
echo -e "${YELLOW}Configuring kubectl...${NC}"
aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $AWS_REGION

# Get ALB DNS name
ALB_DNS=$(kubectl get ingress petstore -n petstore -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "ALB_DNS: $ALB_DNS"

echo -e "\n${YELLOW}Starting Application Functionality Tests...${NC}"
echo -e "${YELLOW}====================${NC}"

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

# Test health endpoint returns 200
run_test "Health endpoint returns 200" "curl -s -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/health | grep -q '200'"

# Test health endpoint response time
run_test "Health endpoint response time" "time curl -s http://$ALB_DNS/api/v1/health -o /dev/null"

# Test GET /pets endpoint
run_test "GET /pets endpoint" "curl -s http://$ALB_DNS/api/v1/pets"

# Test GET /pets endpoint returns 200
run_test "GET /pets endpoint returns 200" "curl -s -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/pets | grep -q '200'"

# Test POST /pets endpoint
run_test "POST /pets endpoint" "curl -s -X POST -H 'Content-Type: application/json' -d '{\"name\":\"TestDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":3,\"price\":100.0,\"status\":\"available\"}' http://$ALB_DNS/api/v1/pets | grep -q 'TestDog'"

# Test POST /pets endpoint returns 201
run_test "POST /pets endpoint returns 201" "curl -s -X POST -H 'Content-Type: application/json' -d '{\"name\":\"TestCat\",\"species\":\"Cat\",\"breed\":\"TestBreed\",\"age\":2,\"price\":80.0,\"status\":\"available\"}' -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/pets | grep -q '201'"

# Get the ID of the first pet
PET_ID=$(curl -s http://$ALB_DNS/api/v1/pets | grep -o '\"id\":[0-9]*' | head -1 | cut -d':' -f2)
echo "Testing with PET_ID: $PET_ID"

# Test GET /pets/{id} endpoint
run_test "GET /pets/{id} endpoint" "curl -s http://$ALB_DNS/api/v1/pets/$PET_ID | grep -q 'id'"

# Test GET /pets/{id} endpoint returns 200
run_test "GET /pets/{id} endpoint returns 200" "curl -s -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/pets/$PET_ID | grep -q '200'"

# Test PUT /pets/{id} endpoint
run_test "PUT /pets/{id} endpoint" "curl -s -X PUT -H 'Content-Type: application/json' -d '{\"name\":\"UpdatedDog\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":4,\"price\":150.0,\"status\":\"available\"}' http://$ALB_DNS/api/v1/pets/$PET_ID | grep -q 'UpdatedDog'"

# Test PUT /pets/{id} endpoint returns 200
run_test "PUT /pets/{id} endpoint returns 200" "curl -s -X PUT -H 'Content-Type: application/json' -d '{\"name\":\"UpdatedAgain\",\"species\":\"Dog\",\"breed\":\"TestBreed\",\"age\":5,\"price\":200.0,\"status\":\"available\"}' -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/pets/$PET_ID | grep -q '200'"

# Test DELETE /pets/{id} endpoint
run_test "DELETE /pets/{id} endpoint" "curl -s -X DELETE http://$ALB_DNS/api/v1/pets/$PET_ID"

# Test DELETE /pets/{id} endpoint returns 204
run_test "DELETE /pets/{id} endpoint returns 204" "curl -s -X DELETE -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/pets/$PET_ID | grep -q '204'"

# Verify pet was deleted
run_test "Verify pet was deleted" "curl -s http://$ALB_DNS/api/v1/pets/$PET_ID -w '%{http_code}' | grep -q '404'"

# Test non-existent endpoint returns 404
run_test "Non-existent endpoint returns 404" "curl -s -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/nonexistent | grep -q '404'"

# Test invalid request returns 400
run_test "Invalid request returns 400" "curl -s -X POST -H 'Content-Type: application/json' -d '{\"invalid\":\"data\"}' -o /dev/null -w '%{http_code}' http://$ALB_DNS/api/v1/pets | grep -q '400'"

# Test concurrent requests
run_test "Concurrent requests" "for i in {1..10}; do curl -s http://$ALB_DNS/api/v1/health -o /dev/null & done; wait"

# Test response time under load
run_test "Response time under load" "time (for i in {1..5}; do curl -s http://$ALB_DNS/api/v1/health -o /dev/null & done; wait)"

# Test CORS headers
run_test "CORS headers" "curl -s -I -H 'Origin: http://example.com' http://$ALB_DNS/api/v1/health | grep -q 'Access-Control-Allow'"

# Print test summary
echo -e "\n${YELLOW}Application Functionality Test Summary${NC}"
echo -e "${YELLOW}====================${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All application functionality tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some application functionality tests failed!${NC}"
  exit 1
fi
