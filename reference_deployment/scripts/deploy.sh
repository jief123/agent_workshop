#!/bin/bash
# Script to deploy the Pet Store application to AWS

echo "Starting deployment of Pet Store application..."

# Step 1: Provision infrastructure with Terraform
echo "Provisioning AWS infrastructure with Terraform..."
cd /home/ubuntu/agent_workshop/deployment/terraform
terraform init
terraform apply -auto-approve

# Step 2: Build and push Docker image
echo "Building and pushing Docker image..."
cd /home/ubuntu/agent_workshop
# Get ECR repository URL from Terraform output
ECR_REPO=$(cd deployment/terraform && terraform output -raw ecr_repository_url)
# Login to ECR
aws ecr get-login-password --region $(cd deployment/terraform && terraform output -raw region) | docker login --username AWS --password-stdin $ECR_REPO
# Build and push image using Dockerfile
docker build -t $ECR_REPO:latest -f deployment/docker/Dockerfile .
docker push $ECR_REPO:latest

# Step 3: Configure kubectl
echo "Configuring kubectl..."
REGION=$(cd deployment/terraform && terraform output -raw region)
CLUSTER_NAME=$(cd deployment/terraform && terraform output -raw cluster_id)
aws eks update-kubeconfig --region ${REGION} --name ${CLUSTER_NAME}

# Step 4: Update Kubernetes configuration files with Terraform outputs
echo "Updating Kubernetes configuration files with Terraform outputs..."
cd /home/ubuntu/agent_workshop/deployment/kubernetes

# Copy from .orig files to ensure we start with clean templates
cp aws-load-balancer-controller-values.yaml.orig aws-load-balancer-controller-values.yaml
cp aws-load-balancer-controller-service-account.yaml.orig aws-load-balancer-controller-service-account.yaml
cp ingress.yaml.orig ingress.yaml
cp deployment.yaml.orig deployment.yaml

# Update aws-load-balancer-controller-values.yaml
sed -i "s|\${CLUSTER_NAME}|${CLUSTER_NAME}|g" aws-load-balancer-controller-values.yaml
sed -i "s|\${REGION}|${REGION}|g" aws-load-balancer-controller-values.yaml
sed -i "s|\${VPC_ID}|$(cd ../terraform && terraform output -raw vpc_id)|g" aws-load-balancer-controller-values.yaml

# Update aws-load-balancer-controller-service-account.yaml
sed -i "s|\${LB_CONTROLLER_ROLE_ARN}|$(cd ../terraform && terraform output -raw load_balancer_controller_role_arn)|g" aws-load-balancer-controller-service-account.yaml

# Update ingress.yaml
sed -i "s|\${PUBLIC_SUBNETS}|$(cd ../terraform && terraform output -json public_subnets | jq -r 'join(",")')|g" ingress.yaml

# Update deployment.yaml with ECR repository URL
sed -i "s|\${ECR_REPO}|${ECR_REPO}|g" deployment.yaml

# Step 5: Deploy application with Kustomize
echo "Deploying application with Kustomize..."
kubectl apply -k .

# Step 6: Deploy AWS Load Balancer Controller
echo "Deploying AWS Load Balancer Controller..."
kubectl apply -f aws-load-balancer-controller-service-account.yaml

echo "Adding EKS Helm repository..."
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Create IngressClass with proper annotations
cat > ingressclass.yaml << EOF
apiVersion: networking.k8s.io/v1
kind: IngressClass
metadata:
  name: alb
  annotations:
    ingressclass.kubernetes.io/is-default-class: "true"
    meta.helm.sh/release-name: "aws-load-balancer-controller"
    meta.helm.sh/release-namespace: "kube-system"
  labels:
    app.kubernetes.io/managed-by: "Helm"
spec:
  controller: ingress.k8s.aws/alb
EOF

# Apply IngressClass
kubectl apply -f ingressclass.yaml

# Set createIngressClassResource to false in values
sed -i 's/createIngressClassResource: true/createIngressClassResource: false/g' aws-load-balancer-controller-values.yaml

echo "Installing AWS Load Balancer Controller..."
# Check if controller already exists and uninstall if needed
if helm list -n kube-system | grep -q aws-load-balancer-controller; then
  echo "AWS Load Balancer Controller already exists, uninstalling..."
  helm uninstall aws-load-balancer-controller -n kube-system
  # Wait for resources to be cleaned up
  sleep 10
fi

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  -f aws-load-balancer-controller-values.yaml

# Step 7: Wait for deployment to complete
echo "Waiting for deployment to complete..."
sleep 60

# Step 8: Get ingress URL
echo "Getting ingress URL..."
kubectl get ingress -n petstore

echo "Deployment complete. Use the ADDRESS field above to access the application."
