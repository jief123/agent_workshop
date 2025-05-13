#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing Existing Pet Store Deployment${NC}"
echo -e "${YELLOW}==================================${NC}"

# Test Kubernetes resources
echo -e "\n${YELLOW}Testing Kubernetes Resources${NC}"

# Check namespace
if kubectl get namespace petstore &>/dev/null; then
  echo -e "${GREEN}✓ Namespace 'petstore' exists${NC}"
else
  echo -e "${RED}✗ Namespace 'petstore' does not exist${NC}"
fi

# Check deployment
if kubectl get deployment petstore -n petstore &>/dev/null; then
  echo -e "${GREEN}✓ Deployment 'petstore' exists${NC}"
  
  # Check replicas
  REPLICAS=$(kubectl get deployment petstore -n petstore -o jsonpath='{.status.readyReplicas}')
  if [ "$REPLICAS" == "2" ]; then
    echo -e "${GREEN}✓ Deployment has 2 ready replicas${NC}"
  else
    echo -e "${RED}✗ Deployment should have 2 replicas, but has $REPLICAS${NC}"
  fi
else
  echo -e "${RED}✗ Deployment 'petstore' does not exist${NC}"
fi

# Check pods
RUNNING_PODS=$(kubectl get pods -n petstore -l app=petstore --field-selector status.phase=Running -o name | wc -l)
if [ "$RUNNING_PODS" -gt "0" ]; then
  echo -e "${GREEN}✓ $RUNNING_PODS pods are running${NC}"
else
  echo -e "${RED}✗ No running pods found${NC}"
fi

# Check service
if kubectl get service petstore -n petstore &>/dev/null; then
  echo -e "${GREEN}✓ Service 'petstore' exists${NC}"
else
  echo -e "${RED}✗ Service 'petstore' does not exist${NC}"
fi

# Check ingress
if kubectl get ingress petstore -n petstore &>/dev/null; then
  echo -e "${GREEN}✓ Ingress 'petstore' exists${NC}"
  
  # Check ALB address
  ALB_DNS=$(kubectl get ingress petstore -n petstore -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
  if [ -n "$ALB_DNS" ]; then
    echo -e "${GREEN}✓ Ingress has ALB address: $ALB_DNS${NC}"
  else
    echo -e "${RED}✗ Ingress does not have an ALB address${NC}"
  fi
else
  echo -e "${RED}✗ Ingress 'petstore' does not exist${NC}"
fi

# Check AWS Load Balancer Controller
if kubectl get deployment aws-load-balancer-controller -n kube-system &>/dev/null; then
  echo -e "${GREEN}✓ AWS Load Balancer Controller is deployed${NC}"
  
  # Check controller replicas
  CONTROLLER_REPLICAS=$(kubectl get deployment aws-load-balancer-controller -n kube-system -o jsonpath='{.status.readyReplicas}')
  if [ -n "$CONTROLLER_REPLICAS" ] && [ "$CONTROLLER_REPLICAS" -gt "0" ]; then
    echo -e "${GREEN}✓ AWS Load Balancer Controller has $CONTROLLER_REPLICAS ready replicas${NC}"
  else
    echo -e "${RED}✗ AWS Load Balancer Controller has no ready replicas${NC}"
  fi
else
  echo -e "${RED}✗ AWS Load Balancer Controller is not deployed${NC}"
fi

echo -e "\n${YELLOW}Testing complete!${NC}"
