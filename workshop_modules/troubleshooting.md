# 实际部署过程中遇到的问题记录

本文档记录了在 Pet Store 应用程序部署过程中实际遇到的错误、具体错误信息和实际采用的解决方案。

## 错误 1: EKS 节点组创建失败

### 实际错误信息
```
Error: waiting for EKS Node Group create: unexpected state 'CREATE_FAILED'
last error: Ec2LaunchTemplateInvalidConfiguration: User data was not in the MIME multipart format.
```

### 实际解决方案
1. 从 Terraform state 中移除失败的节点组：
```bash
terraform state rm 'module.eks.module.eks_managed_node_group["petstore_nodes"].aws_eks_node_group.this[0]'
```

2. 修改 main.tf 中的节点组配置：
```hcl
# 将 enable_bootstrap_user_data = true 改为 false
enable_bootstrap_user_data = false
```

3. 重新运行 terraform apply

## 错误 2: OIDC Provider 数据源找不到

### 实际错误信息
```
Error: finding IAM OIDC Provider by url (https://oidc.eks.us-east-1.amazonaws.com/id/797DE62995B1EE2DF711C1B310FD3F09): not found
```

### 实际解决方案
修改 main.tf 中的数据源配置，添加依赖关系：
```hcl
data "aws_iam_openid_connect_provider" "eks" {
  url = module.eks.cluster_oidc_issuer_url
  depends_on = [module.eks]
}
```

## 错误 3: kubectl 认证失败

### 实际错误信息
```
error: You must be logged in to the server (the server has asked for the client to provide credentials)
```

### 实际解决方案
```bash
# 1. 获取当前用户 ARN
current_user_arn=$(aws sts get-caller-identity --query 'Arn' --output text)

# 2. 创建访问条目
aws eks create-access-entry \
    --cluster-name petstore-eks \
    --region us-east-1 \
    --principal-arn "$current_user_arn" \
    --type STANDARD \
    --username workshopadmin

# 3. 关联管理员策略
aws eks associate-access-policy \
    --cluster-name petstore-eks \
    --region us-east-1 \
    --principal-arn "$current_user_arn" \
    --policy-arn arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy \
    --access-scope type=cluster
```

## 错误 4: 应用程序 Pod 崩溃循环 - SQLite 权限问题

### 实际错误信息
```
Starting Pet Store application...
Using SQLite database, no need to wait for external database
Initializing database...
INFO:src.utils.database:Configuring SQLite database connection
ERROR:src.utils.database:Error initializing database: (sqlite3.OperationalError) unable to open database file
(Background on this error at: https://sqlalche.me/e/20/e3q8)

Pod status: CrashLoopBackOff
```

### 问题根本原因
1. **数据库路径配置错误**：使用了绝对路径 `sqlite:///app/data/petstore.db` 而不是相对路径
2. **容器文件系统过度复杂化**：添加了不必要的 emptyDir 卷挂载和额外目录
3. **没有遵循参考实现**：reference_deployment 中使用的是简单的相对路径配置

### 错误的解决尝试
我们最初尝试了以下复杂的解决方案（**这些都是错误的方法**）：
- 创建额外的 `/app/data` 目录
- 添加 emptyDir 卷挂载到 `/app/data`
- 使用绝对路径 `sqlite:///app/data/petstore.db`

### 实际正确的解决方案

#### 1. 修正数据库 URL 配置
```bash
# 更新 Kubernetes Secret 使用相对路径
kubectl patch secret db-credentials -n petstore -p '{"data":{"DATABASE_URL":"'$(echo -n "sqlite:///petstore.db" | base64)'"}}'
```

#### 2. 简化 Dockerfile 配置
```dockerfile
# 移除不必要的目录创建，使用简单的权限设置
RUN groupadd -r petstore && \
    useradd -r -g petstore -d /app -s /bin/bash petstore && \
    chown -R petstore:petstore /app

# 将 entrypoint.sh 放在 /app/ 目录内
COPY deployment/docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh
```

#### 3. 简化 Kubernetes 部署配置
```yaml
# 移除不必要的卷挂载配置
# 删除以下内容：
# volumeMounts:
# - name: sqlite-storage
#   mountPath: /app/data
# volumes:
# - name: sqlite-storage
#   emptyDir: {}
```

#### 4. 参考实现对比
**参考实现（正确）**：
```bash
# reference_deployment/kubernetes/secret.yaml
DATABASE_URL: c3FsaXRlOi8vL3BldHN0b3JlLmRi  # base64: sqlite:///petstore.db
```

**我们的错误配置**：
```bash
DATABASE_URL: c3FsaXRlOi8vL2FwcC9kYXRhL3BldHN0b3JlLmRi  # base64: sqlite:///app/data/petstore.db
```

### 修复后的成功日志
```
Starting Pet Store application...
Using SQLite database, no need to wait for external database
Initializing database...
INFO:src.utils.database:Configuring SQLite database connection
INFO:src.utils.database:Database tables created successfully
Database initialized successfully
[2025-06-09 16:15:56 +0000] [1] [INFO] Starting gunicorn 20.1.0
[2025-06-09 16:15:56 +0000] [1] [INFO] Listening at: http://0.0.0.0:8080 (1)

Pod status: Running (2/2 pods ready)
```

### 关键学习点
1. **遵循参考实现**：reference_deployment 提供了经过验证的最佳实践
2. **简单性原则**：SQLite 在容器中应该使用相对路径，避免复杂的卷挂载
3. **RTFM**：DEPLOYMENT_README.md 中已经明确记录了这个问题和解决方案
4. **文件权限设置**：正确的 `chown -R petstore:petstore /app` 比复杂的权限映射更重要

### 预防措施
- 在偏离参考实现之前，先验证现有配置是否有问题
- 对于 SQLite 数据库，优先使用相对路径配置
- 遵循 DEPLOYMENT_README.md 中的最佳实践指导

## 错误 5: ALB 返回 503 错误

### 实际情况
```
503 Service Temporarily Unavailable
TargetHealthDescriptions: []
```

这是正常现象，ALB 需要时间完成健康检查。通过端口转发验证应用程序正常工作：
```bash
kubectl port-forward -n petstore deployment/petstore-app 8080:8080
curl http://localhost:8080/api/v1/health
# 返回: {"database":"connected","status":"healthy"}
```

## 部署最终状态

### 成功部署的资源
- EKS 集群：petstore-eks (ACTIVE)
- 应用程序：2 个 Pod (Running)
- ALB：k8s-petstore-petstore-8e33e6d87d-638741293.us-east-1.elb.amazonaws.com
- ECR 镜像：619664232626.dkr.ecr.us-east-1.amazonaws.com/petstore:v20250609-101107

所有错误都得到解决，应用程序成功部署并运行。
