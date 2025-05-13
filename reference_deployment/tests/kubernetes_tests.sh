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

echo -e "\n${YELLOW}Starting Kubernetes Resource Tests...${NC}"
echo -e "${YELLOW}====================${NC}"

# Test namespace exists
run_test "Namespace exists" "kubectl get namespace petstore"

# Test namespace has correct labels
run_test "Namespace has correct labels" "kubectl get namespace petstore -o jsonpath='{.metadata.labels}' | grep -q 'app: petstore'"

# Test configmap exists
run_test "ConfigMap exists" "kubectl get configmap app-config -n petstore"

# Test configmap has correct data
run_test "ConfigMap has correct data" "kubectl get configmap app-config -n petstore -o jsonpath='{.data}' | grep -q 'API_VERSION'"

# Test secret exists
run_test "Secret exists" "kubectl get secret db-credentials -n petstore"

# Test secret has correct data
run_test "Secret has correct data" "kubectl get secret db-credentials -n petstore -o jsonpath='{.data}' | grep -q 'DATABASE_URL'"

# Test deployment exists
run_test "Deployment exists" "kubectl get deployment petstore -n petstore"

# Test deployment has correct replicas
run_test "Deployment has correct replicas" "kubectl get deployment petstore -n petstore -o jsonpath='{.spec.replicas}' | grep -q '2'"

# Test deployment has correct image
run_test "Deployment has correct image" "kubectl get deployment petstore -n petstore -o jsonpath='{.spec.template.spec.containers[0].image}' | grep -q 'petstore'"

# Test deployment has resource limits
run_test "Deployment has resource limits" "kubectl get deployment petstore -n petstore -o jsonpath='{.spec.template.spec.containers[0].resources.limits}' | grep -q 'cpu'"

# Test deployment has resource requests
run_test "Deployment has resource requests" "kubectl get deployment petstore -n petstore -o jsonpath='{.spec.template.spec.containers[0].resources.requests}' | grep -q 'memory'"

# Test deployment has liveness probe
run_test "Deployment has liveness probe" "kubectl get deployment petstore -n petstore -o jsonpath='{.spec.template.spec.containers[0].livenessProbe}' | grep -q 'httpGet'"

# Test deployment has readiness probe
run_test "Deployment has readiness probe" "kubectl get deployment petstore -n petstore -o jsonpath='{.spec.template.spec.containers[0].readinessProbe}' | grep -q 'httpGet'"

# Test service exists
run_test "Service exists" "kubectl get service petstore -n petstore"

# Test service has correct type
run_test "Service has correct type" "kubectl get service petstore -n petstore -o jsonpath='{.spec.type}' | grep -q 'ClusterIP'"

# Test service has correct port
run_test "Service has correct port" "kubectl get service petstore -n petstore -o jsonpath='{.spec.ports[0].port}' | grep -q '80'"

# Test service has correct target port
run_test "Service has correct target port" "kubectl get service petstore -n petstore -o jsonpath='{.spec.ports[0].targetPort}' | grep -q '8080'"

# Test ingress exists
run_test "Ingress exists" "kubectl get ingress petstore -n petstore"

# Test ingress has correct class
run_test "Ingress has correct class" "kubectl get ingress petstore -n petstore -o jsonpath='{.spec.ingressClassName}' | grep -q 'alb'"

# Test ingress has correct path
run_test "Ingress has correct path" "kubectl get ingress petstore -n petstore -o jsonpath='{.spec.rules[0].http.paths[0].path}' | grep -q '/'"

# Test ingress has correct backend service
run_test "Ingress has correct backend service" "kubectl get ingress petstore -n petstore -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.name}' | grep -q 'petstore'"

# Test ingress has correct backend service port
run_test "Ingress has correct backend service port" "kubectl get ingress petstore -n petstore -o jsonpath='{.spec.rules[0].http.paths[0].backend.service.port.number}' | grep -q '80'"

# Test ingress has correct annotations
run_test "Ingress has correct annotations" "kubectl get ingress petstore -n petstore -o jsonpath='{.metadata.annotations}' | grep -q 'alb.ingress.kubernetes.io'"

# Test ingress class exists
run_test "IngressClass exists" "kubectl get ingressclass alb"

# Test ingress class has correct controller
run_test "IngressClass has correct controller" "kubectl get ingressclass alb -o jsonpath='{.spec.controller}' | grep -q 'ingress.k8s.aws/alb'"

# Test ingress class has correct annotations
run_test "IngressClass has correct annotations" "kubectl get ingressclass alb -o jsonpath='{.metadata.annotations}' | grep -q 'ingressclass.kubernetes.io/is-default-class'"

# Test AWS Load Balancer Controller is running
run_test "AWS Load Balancer Controller is running" "kubectl get deployment aws-load-balancer-controller -n kube-system"

# Test AWS Load Balancer Controller has correct replicas
run_test "AWS Load Balancer Controller has correct replicas" "kubectl get deployment aws-load-balancer-controller -n kube-system -o jsonpath='{.status.readyReplicas}' | grep -q '[1-9]'"

# Test AWS Load Balancer Controller service account exists
run_test "AWS Load Balancer Controller service account exists" "kubectl get serviceaccount aws-load-balancer-controller -n kube-system"

# Test AWS Load Balancer Controller service account has correct annotations
run_test "AWS Load Balancer Controller service account has correct annotations" "kubectl get serviceaccount aws-load-balancer-controller -n kube-system -o jsonpath='{.metadata.annotations}' | grep -q 'eks.amazonaws.com/role-arn'"

# Test pods are running
run_test "Pods are running" "kubectl get pods -n petstore -l app=petstore --field-selector status.phase=Running | grep -q petstore"

# Test pods are ready
run_test "Pods are ready" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[*].status.containerStatuses[0].ready}' | grep -q 'true'"

# Test pods have correct image
run_test "Pods have correct image" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.containers[0].image}' | grep -q 'petstore'"

# Test pods have correct environment variables
run_test "Pods have correct environment variables" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.containers[0].envFrom}' | grep -q 'configMapRef'"

# Test pods are running as non-root
run_test "Pods are running as non-root" "kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].spec.securityContext.runAsNonRoot}' | grep -q 'true' || kubectl exec -n petstore \$(kubectl get pods -n petstore -l app=petstore -o jsonpath='{.items[0].metadata.name}') -- id -u | grep -v '0'"

# Print test summary
echo -e "\n${YELLOW}Kubernetes Resource Test Summary${NC}"
echo -e "${YELLOW}====================${NC}"
echo -e "Total tests: ${TOTAL}"
echo -e "${GREEN}Passed: ${PASSED}${NC}"
echo -e "${RED}Failed: ${FAILED}${NC}"

if [ $FAILED -eq 0 ]; then
  echo -e "\n${GREEN}All Kubernetes resource tests passed!${NC}"
  exit 0
else
  echo -e "\n${RED}Some Kubernetes resource tests failed!${NC}"
  exit 1
fi
