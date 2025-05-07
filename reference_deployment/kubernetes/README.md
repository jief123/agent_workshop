# Kubernetes Configuration for Pet Store Application

This directory contains the Kubernetes manifests for deploying the Pet Store application with SQLite as the embedded database.

## Files

- `namespace.yaml`: Creates the petstore namespace
- `configmap.yaml`: Application configuration settings
- `secret.yaml`: SQLite database connection string
- `deployment.yaml`: Application deployment configuration
- `service.yaml`: ClusterIP service for internal communication
- `ingress-class.yaml`: ALB ingress class definition
- `ingress.yaml`: ALB ingress configuration for external access
- `kustomization.yaml`: Kustomize configuration for easy deployment

## AWS Load Balancer Controller Files

- `aws-load-balancer-controller-service-account.yaml`: Service account for AWS Load Balancer Controller
- `aws-load-balancer-controller-values.yaml`: Configuration for AWS Load Balancer Controller Helm chart

## Deployment Instructions

### Deploy the application

```bash
kubectl apply -k .
```

### Deploy AWS Load Balancer Controller

```bash
# Create service account
kubectl apply -f aws-load-balancer-controller-service-account.yaml

# Install controller using Helm
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  -f aws-load-balancer-controller-values.yaml
```
