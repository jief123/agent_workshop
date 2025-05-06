# Pet Store Deployment Requirements

## Overview

This document outlines the requirements for deploying the Pet Store microservice to a production environment using Amazon EKS (Elastic Kubernetes Service). It covers compute resources, storage, networking, scaling, configuration, security, monitoring, and disaster recovery considerations.

## Compute Resources

### Container Requirements

- **Base Image**: Python 3.9 or later
- **CPU**: 
  - Request: 0.25 vCPU
  - Limit: 0.5 vCPU
- **Memory**: 
  - Request: 256 MiB
  - Limit: 512 MiB
- **Replicas**: 
  - Minimum: 2
  - Maximum: 10

### Node Requirements

- **Instance Type**: t3.small (2 vCPU, 2 GiB memory)
- **Node Group Size**: 
  - Minimum: 2
  - Maximum: 5
- **Operating System**: Amazon Linux 2

## Storage Requirements

### Application Storage

- **Type**: No persistent storage required for application containers
- **Ephemeral Storage**: 1 GiB per pod

### Database Storage

- **Development**: SQLite (file-based, no separate storage needed)
- **Production**: AWS RDS (PostgreSQL)
  - Storage: 20 GiB gp3
  - Backup: Daily snapshots, 7-day retention

## Networking Configuration

### Service Exposure

- **Service Type**: ClusterIP (internal) with Ingress for external access
- **Ports**:
  - Container Port: 8080
  - Service Port: 80
- **Health Check Path**: `/api/v1/health`

### Ingress Requirements

- **TLS**: Required for production
- **Path**: `/api/v1/*`
- **CORS**: Allow from specified origins

### Network Policies

- Allow inbound traffic to pods only from the ingress controller
- Allow outbound traffic from pods to the database
- Deny all other traffic

## Scaling Parameters

### Horizontal Pod Autoscaler

- **Metric**: CPU utilization
- **Target**: 70%
- **Min Replicas**: 2
- **Max Replicas**: 10
- **Scale-up Behavior**: 
  - Scale up by 2 pods at a time
  - Wait 60 seconds between scaling operations
- **Scale-down Behavior**: 
  - Scale down by 1 pod at a time
  - Wait 300 seconds between scaling operations

### Cluster Autoscaler

- **Min Nodes**: 2
- **Max Nodes**: 5
- **Scale-up Threshold**: 80% resource utilization
- **Scale-down Threshold**: 40% resource utilization

## Environment Variables and Configuration

### Required Environment Variables

- `DATABASE_URL`: Connection string for the database
- `ENVIRONMENT`: Deployment environment (development, staging, production)
- `LOG_LEVEL`: Logging level (INFO, DEBUG, etc.)

### ConfigMaps

- `app-config`: General application configuration
  - `CORS_ORIGINS`: Allowed CORS origins
  - `API_VERSION`: API version string
  - `PAGINATION_LIMIT`: Default pagination limit

### Secrets

- `db-credentials`: Database credentials
  - `DB_USER`: Database username
  - `DB_PASSWORD`: Database password

## Security Requirements

### Pod Security

- Run as non-root user
- Read-only file system where possible
- Drop all capabilities and add only those required
- Run with seccomp profile

### Network Security

- TLS for all external traffic
- Network policies to restrict pod communication
- Service mesh for mTLS between services (optional)

### Secret Management

- Use Kubernetes Secrets for sensitive data
- Consider AWS Secrets Manager for production credentials

### IAM and RBAC

- Use IAM roles for service accounts
- Principle of least privilege for all permissions
- RBAC policies for Kubernetes resources

## Monitoring and Logging

### Metrics

- **Application Metrics**:
  - Request count
  - Request latency
  - Error rate
  - CPU and memory usage
- **Collection**: Prometheus

### Logging

- **Log Format**: JSON
- **Collection**: Fluent Bit to CloudWatch Logs
- **Retention**: 30 days

### Alerting

- Alert on:
  - High error rate (>1%)
  - High latency (p95 > 500ms)
  - High CPU usage (>85%)
  - High memory usage (>85%)
  - Pod restarts

## Backup and Disaster Recovery

### Backup Strategy

- **Database**: Daily automated backups
- **Configuration**: Store in version control
- **Backup Retention**: 7 days

### Disaster Recovery

- **RTO (Recovery Time Objective)**: 1 hour
- **RPO (Recovery Point Objective)**: 24 hours
- **Strategy**: Restore from latest backup to new cluster

## Deployment Strategy

### CI/CD Pipeline

- **Build**: Automated on commit to main branch
- **Test**: Run unit and integration tests
- **Deploy**: 
  - Development: Automatic on successful tests
  - Production: Manual approval required

### Deployment Method

- **Strategy**: Rolling update
- **Max Unavailable**: 25%
- **Max Surge**: 25%

### Rollback Procedure

- Automatic rollback on failed health checks
- Manual rollback option in deployment pipeline

## Compliance and Governance

### Resource Tagging

- **Required Tags**:
  - `Environment`: development, staging, production
  - `Application`: pet-store
  - `Owner`: team-name
  - `Cost-Center`: cost-center-id

### Resource Limits

- Set resource quotas for namespaces
- Set LimitRange for containers without explicit limits
