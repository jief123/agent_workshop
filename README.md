# IT Ops Acceleration with AI Agents Workshop

This workshop demonstrates how to leverage AI agents for IT operations tasks through two complementary approaches: first experiencing AI agents to understand their capabilities, then building custom agents to automate specific tasks. You'll learn what makes an effective AI agent (LLM loop + Tools + Knowledge) through hands-on experience with Amazon Q CLI, then apply this understanding to create your own agents using Rapid Assistant SDK.

## Workshop Structure

This workshop is organized into two main sections:

### Part 1: Understanding AI Agents Through Experience (Modules 1-2)
Experience firsthand how AI agents work by using Amazon Q CLI as your personal assistant for IT operations tasks. Through the practical scenario of transforming a Pet Store microservice, you'll observe and interact with the core components of an effective agent: the LLM reasoning loop, tool usage, and knowledge application.

### Part 2: Building Custom AI Agents (Modules 3-4)
Apply your understanding of agent architecture to build your own agents using Rapid Assistant SDK and the Model Context Protocol (MCP). Create a Pet Store API agent and then develop custom agents for real-world use cases in your organization.

## Workshop Objectives

By the end of this workshop, you will:
- Understand the fundamental components of an AI agent: LLM loop + Tools + Knowledge
- Experience how to effectively interact with AI agents through well-crafted prompts
- Learn how agents make decisions about which tools to use and when
- Observe how agents leverage contextual knowledge to solve complex problems
- Understand the Model Context Protocol (MCP) and how it extends agent capabilities
- Build a custom Pet Store agent using Rapid Assistant SDK and MCP
- Design and implement agents for real-world use cases
- Learn best practices for AI-assisted infrastructure management

## Prerequisites

- AWS Account with appropriate permissions
- AWS CLI configured
- Amazon Q CLI installed
- Docker installed
- kubectl installed
- Python 3.8+ installed
- Basic understanding of containerization and Kubernetes

## Workshop Architecture

This workshop uses a simple Pet Store microservice as the application to be deployed and extended. The application is a RESTful API that allows users to manage pets in a store inventory.

### Application Components:
- RESTful API built with Python (Flask)
- SQLite database for local development
- Layered architecture (Controllers, Services, Models)

### Target Deployment Architecture:
- Amazon EKS for container orchestration
- Application deployed as Kubernetes pods
- Service and Ingress for external access
- AWS RDS for production database (optional extension)

### Agent Architecture:
- Pet Store API wrapped as an MCP server
- Custom tools exposed through the MCP protocol
- Amazon Q CLI integration with the MCP server
- Rapid Assistant SDK for agent development

## Design Documentation

The `design_docs` directory contains comprehensive documentation about the application architecture, API specifications, data models, and deployment requirements. These documents serve as the starting point for the transformation process.

Key design documents include:
- **architecture.md**: Overall application architecture and component interactions
- **api_spec.md**: API endpoints, request/response formats, and examples
- **data_model.md**: Database schema and entity relationships
- **deployment_requirements.md**: Infrastructure requirements and constraints

These design documents are crucial for Amazon Q CLI to understand the application context when assisting with transformation tasks.

## Workshop Modules

### Module 1: Understanding the Pet Store Microservice
- Explore the application architecture using the design documentation
- Run the application locally
- Test the API endpoints
- Review the code structure and dependencies

### Module 2: Experiencing AI Agents in Action
- Use Amazon Q CLI to analyze the design documents
- Learn to craft effective prompts for infrastructure tasks
- Observe how the agent processes your prompts and makes decisions
- Experience how the agent uses tools to accomplish tasks
- See how the agent leverages knowledge from design documents and context
- Generate infrastructure code for EKS deployment as a practical exercise
- Understand the LLM reasoning loop in real-time problem solving

### Module 3: Building a Pet Store Agent with MCP and Prompt-Driven Development
- Apply your understanding of agent architecture (LLM loop + Tools + Knowledge)
- Learn how to use Rapid Assistant SDK to build custom agents
- Apply prompt-driven development to design and implement agent tools
- Package the Pet Store API as an MCP server
- Create custom tools that interact with the Pet Store API
- Configure Amazon Q CLI to use your custom MCP server
- Build complex workflows for pet store operations
- Deploy your MCP server to AWS

### Module 4: Build Your Own Agent - Customer Use Case Challenge
- Work in groups to identify a real-world use case from your organization
- Design and implement a custom agent using MCP and Rapid Assistant SDK
- Present your solution to the workshop (5 minutes per group)
- Learn from other teams' approaches and implementations

## Using Amazon Q CLI for Transformation

Throughout this workshop, you'll use Amazon Q CLI to assist with various tasks. Here are some example prompts you can use:

1. Analyzing design documents:
   ```
   q "Analyze the design documents in the design_docs directory and summarize the key requirements for containerization and deployment"
   ```

2. Creating a Dockerfile:
   ```
   q "Based on the application requirements in design_docs/deployment_requirements.md, create a Dockerfile for the Pet Store application"
   ```

3. Generating Kubernetes manifests:
   ```
   q "Create Kubernetes deployment and service manifests for the Pet Store application based on the architecture described in design_docs/architecture.md"
   ```

4. Developing Terraform code:
   ```
   q "Generate Terraform code to provision an EKS cluster that meets the requirements in design_docs/deployment_requirements.md"
   ```

5. Building a Pet Store MCP agent with prompt-driven development:
   ```
   q "Design a tool definition for listing pets in a store using the Rapid Assistant SDK"
   q "How can I improve the search_pets tool to handle case sensitivity and partial matches better?"
   q "Help me create an MCP server using Rapid Assistant SDK that exposes the Pet Store API operations as tools"
   ```

6. Interacting with the Pet Store agent:
   ```
   q "Show me all the pets in the store"
   q "Add a new dog named Max that's 3 years old with a price of $500"
   ```

## Workshop Flow

This workshop is designed to be hands-on, with participants first using Amazon Q CLI to enhance their personal productivity, and then building their own agents to automate specific tasks. The Pet Store microservice serves as a consistent example throughout the workshop, first as an application to be deployed and then as an API to be wrapped as an agent.

In the first part (Modules 1-2), you'll learn what makes an effective AI agent (LLM loop + Tools + Knowledge) through hands-on experience with Amazon Q CLI. In the second part (Modules 3-4), you'll learn how to build custom agents that can run assigned tasks using Rapid Assistant SDK and the Model Context Protocol.

## Getting Started

1. Clone this repository
2. Review the design documentation in the `design_docs` directory
3. Follow the instructions in `workshop_modules/module1.md` to begin the workshop

## Resources

- [Amazon Q CLI Documentation](https://aws.amazon.com/q/)
- [Amazon EKS Documentation](https://aws.amazon.com/eks/)
- [AWS MCP Server Documentation](https://awslabs.github.io/mcp/)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
- [Rapid Assistant Documentation](https://docs.rapid-assistant.example.com)
