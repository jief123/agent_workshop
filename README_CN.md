# 使用 AI 智能体加速 IT 运维工作坊

本工作坊展示了如何通过两种互补的方法利用 AI 智能体执行 IT 运维任务：首先体验 AI 智能体以了解其能力，然后构建自定义智能体来自动化特定任务。您将通过使用 Amazon Q CLI 的实践经验了解什么构成了一个有效的 AI 智能体（LLM 循环 + 工具 + 知识），然后应用这些理解来使用 Rapid Assistant SDK 创建您自己的智能体。

## 工作坊结构

本工作坊分为两个主要部分：

### 第一部分：通过体验理解 AI 智能体（模块 1-2）
通过使用 Amazon Q CLI 作为 IT 运维任务的个人助手，亲身体验 AI 智能体的工作方式。通过转换宠物商店微服务的实际场景，您将观察并与有效智能体的核心组件互动：LLM 推理循环、工具使用和知识应用。

### 第二部分：构建自定义 AI 智能体（模块 3-4）
应用您对智能体架构的理解，使用 Rapid Assistant SDK 和模型上下文协议（MCP）构建您自己的智能体。创建宠物商店 API 智能体，然后为您组织中的实际用例开发自定义智能体。

## 工作坊目标

完成本工作坊后，您将能够：
- 理解 AI 智能体的基本组件：LLM 循环 + 工具 + 知识
- 体验如何通过精心设计的提示有效地与 AI 智能体互动
- 了解智能体如何决定何时使用哪些工具
- 观察智能体如何利用上下文知识解决复杂问题
- 理解模型上下文协议（MCP）及其如何扩展智能体能力
- 使用 Rapid Assistant SDK 和 MCP 构建自定义宠物商店智能体
- 为实际用例设计和实现智能体
- 学习 AI 辅助基础设施管理的最佳实践

## 前提条件

- 具有适当权限的 AWS 账户
- 已配置 AWS CLI
- 已安装 Amazon Q CLI
- 已安装 Docker
- 已安装 kubectl
- 已安装 Python 3.8+
- 对容器化和 Kubernetes 有基本了解

## 工作坊架构

本工作坊使用简单的宠物商店微服务作为要部署和扩展的应用程序。该应用程序是一个 RESTful API，允许用户管理商店库存中的宠物。

### 应用程序组件：
- 使用 Python (Flask) 构建的 RESTful API
- 用于本地开发的 SQLite 数据库
- 分层架构（控制器、服务、模型）

### 目标部署架构：
- 使用 Amazon EKS 进行容器编排
- 应用程序部署为 Kubernetes pods
- 服务和入口用于外部访问
- AWS RDS 用于生产数据库（可选扩展）

### 智能体架构：
- 宠物商店 API 封装为 MCP 服务器
- 通过 MCP 协议暴露自定义工具
- Amazon Q CLI 与 MCP 服务器集成
- 使用 Rapid Assistant SDK 进行智能体开发

## 设计文档

`design_docs` 目录包含有关应用程序架构、API 规范、数据模型和部署要求的全面文档。这些文档作为转换过程的起点。

主要设计文档包括：
- **architecture.md**：整体应用程序架构和组件交互
- **api_spec.md**：API 端点、请求/响应格式和示例
- **data_model.md**：数据库模式和实体关系
- **deployment_requirements.md**：基础设施要求和约束

这些设计文档对于 Amazon Q CLI 在协助转换任务时理解应用程序上下文至关重要。

## 工作坊模块

### 模块 1：了解宠物商店微服务
- 使用设计文档探索应用程序架构
- 在本地运行应用程序
- 测试 API 端点
- 审查代码结构和依赖关系

### 模块 2：体验 AI 智能体实战
- 使用 Amazon Q CLI 分析设计文档
- 学习为基础设施任务制定有效提示
- 观察智能体如何处理您的提示并做出决策
- 体验智能体如何使用工具完成任务
- 了解智能体如何利用设计文档和上下文中的知识
- 生成 EKS 部署的基础设施代码作为实践练习
- 理解实时问题解决中的 LLM 推理循环

### 模块 3：使用 MCP 和提示驱动开发构建宠物商店智能体
- 应用您对智能体架构的理解（LLM 循环 + 工具 + 知识）
- 学习如何使用 Rapid Assistant SDK 构建自定义智能体
- 应用提示驱动开发来设计和实现智能体工具
- 将宠物商店 API 打包为 MCP 服务器
- 创建与宠物商店 API 交互的自定义工具
- 配置 Amazon Q CLI 使用您的自定义 MCP 服务器
- 构建宠物商店操作的复杂工作流程
- 将 MCP 服务器部署到 AWS

### 模块 4：构建您自己的智能体 - 客户用例挑战
- 分组确定来自您组织的实际用例
- 使用 MCP 和 Rapid Assistant SDK 设计和实现自定义智能体
- 向工作坊展示您的解决方案（每组 5 分钟）
- 从其他团队的方法和实现中学习

## 使用 Amazon Q CLI 进行转换

在本工作坊中，您将使用 Amazon Q CLI 协助完成各种任务。以下是一些可以使用的示例提示：

1. 分析设计文档：
   ```
   q "分析 design_docs 目录中的设计文档，并总结容器化和部署的关键要求"
   ```

2. 创建 Dockerfile：
   ```
   q "根据 design_docs/deployment_requirements.md 中的应用程序要求，为宠物商店应用程序创建 Dockerfile"
   ```

3. 生成 Kubernetes 清单：
   ```
   q "根据 design_docs/architecture.md 中描述的架构，为宠物商店应用程序创建 Kubernetes 部署和服务清单"
   ```

4. 开发 Terraform 代码：
   ```
   q "生成 Terraform 代码，以配置满足 design_docs/deployment_requirements.md 中要求的 EKS 集群"
   ```

5. 使用提示驱动开发构建宠物商店 MCP 智能体：
   ```
   q "使用 Rapid Assistant SDK 设计一个用于列出商店中宠物的工具定义"
   q "如何改进 search_pets 工具以更好地处理大小写敏感性和部分匹配？"
   q "帮我使用 Rapid Assistant SDK 创建一个 MCP 服务器，该服务器将宠物商店 API 操作作为工具暴露"
   ```

6. 与宠物商店智能体交互：
   ```
   q "显示商店中的所有宠物"
   q "添加一只名为 Max 的 3 岁狗，价格为 500 美元"
   ```

## 工作坊流程

本工作坊设计为动手实践，参与者首先使用 Amazon Q CLI 提高个人生产力，然后构建自己的智能体来自动化特定任务。宠物商店微服务在整个工作坊中作为一致的示例，首先作为要部署的应用程序，然后作为要封装为智能体的 API。

在第一部分（模块 1-2）中，您将通过使用 Amazon Q CLI 的实践经验了解什么构成了一个有效的 AI 智能体（LLM 循环 + 工具 + 知识）。在第二部分（模块 3-4）中，您将学习如何使用 Rapid Assistant SDK 和模型上下文协议构建可以运行指定任务的自定义智能体。

## 开始使用

1. 克隆此存储库
2. 查看 `design_docs` 目录中的设计文档
3. 按照 `workshop_modules/module1.md` 中的说明开始工作坊

## 资源

- [Amazon Q CLI 文档](https://aws.amazon.com/q/)
- [Amazon EKS 文档](https://aws.amazon.com/eks/)
- [AWS MCP Server 文档](https://awslabs.github.io/mcp/)
- [Kubernetes 文档](https://kubernetes.io/docs/home/)
- [Rapid Assistant 文档](https://docs.rapid-assistant.example.com)
