# Workshop Plan: Accelerating IT Ops with AI Agents

## Overview
This workshop demonstrates how to leverage AI agents for IT operations tasks through two complementary approaches: first experiencing AI agents to understand their capabilities, then building custom agents to automate specific tasks. Participants will learn what makes an effective AI agent (LLM loop + Tools + Knowledge) through hands-on experience with Amazon Q CLI, then apply this understanding to create their own agents.

## Project Structure
```
agent_workshop/
├── README.md                     # Main workshop instructions
├── README_CN.md                  # Chinese version of workshop instructions
├── petstore-app/                 # Simple microservice source code
│   ├── src/                      # Application source code
│   │   ├── controllers/          # API controllers
│   │   ├── models/               # Data models
│   │   ├── services/             # Business logic
│   │   └── utils/                # Helper functions
│   ├── tests/                    # Unit tests
│   ├── requirements.txt          # Dependencies
│   └── app.py                    # Main application entry point
├── design_docs/                  # Design documentation
│   ├── architecture.md           # Application architecture
│   ├── api_spec.md               # API specifications
│   ├── data_model.md             # Data model documentation
│   ├── deployment_requirements.md # Deployment requirements
│   └── diagrams/                 # Architecture diagrams
│       ├── application_flow.txt  # Application flow diagram
│       └── deployment_arch.txt   # Deployment architecture diagram
├── deployment/                   # Deployment resources (empty directories for participants to fill)
│   ├── docker/                   # For Dockerfile
│   ├── kubernetes/               # For Kubernetes manifests
│   ├── terraform/                # For Terraform code
│   ├── scripts/                  # For helper scripts
│   └── workflows/                # For deployment workflows
├── reference_deployment/         # Reference implementation for participants who need help
│   ├── docker/                   # Reference Dockerfile
│   ├── kubernetes/               # Reference Kubernetes manifests
│   ├── terraform/                # Reference Terraform code
│   ├── scripts/                  # Reference helper scripts
│   └── workflows/                # Reference deployment workflows
└── workshop_modules/             # Workshop documentation
    ├── module1.md                # Module 1: Understanding the application
    ├── module2.md                # Module 2: Experiencing AI Agents in Action
    ├── module3.md                # Module 3: Building a Pet Store Agent with MCP
    ├── module4.md                # Module 4: Build Your Own Agent
    ├── facilitator_guide.md      # Guide for workshop facilitators
    ├── facilitator_guide_CN.md   # Chinese version of facilitator guide
    └── advanced_topics.md        # Additional topics and extensions
```

## Implementation Plan

### Step 1: Create the Pet Store Microservice
- Develop a simple RESTful API for a pet store using Python (Flask)
- Implement basic CRUD operations for pet management
- Include a simple database layer (SQLite for local development)
- Add comprehensive API documentation
- Create unit tests for core functionality
- Ensure the application runs locally without containerization

### Step 2: Create Design Documentation
- **architecture.md**:
  - Component diagram showing API, business logic, and data layers
  - Request flow from client to database and back
  - Integration points and dependencies
  - Scalability considerations
  - Security architecture

- **api_spec.md**:
  - RESTful endpoints (GET /pets, POST /pets, GET /pets/{id}, etc.)
  - Request and response formats with JSON examples
  - Query parameters and pagination
  - Error handling and status codes
  - Authentication and authorization requirements

- **data_model.md**:
  - Entity relationship diagrams
  - Database schema definitions
  - Object models and their relationships
  - Data validation rules
  - Sample data

- **deployment_requirements.md**:
  - Compute resources (CPU, memory)
  - Storage requirements
  - Networking configuration
  - Scaling parameters
  - Environment variables and configuration
  - Security requirements
  - Monitoring and logging needs
  - Backup and disaster recovery considerations
### Step 3: Prepare Workshop Documentation
- Create step-by-step guides for each module
- Include example Amazon Q CLI prompts for participants to use
- Document expected outcomes and validation steps
- Create troubleshooting guides for common issues
- Design guided discovery activities for Module 2
- Create reflection questions for the critical transition after Module 2
- Develop tool templates for Module 3

### Step 4: Create Empty Deployment Structure and Reference Implementation
- Set up empty directories for deployment resources
- Participants will use Amazon Q CLI to generate all deployment code themselves
- Create a reference implementation in the reference_deployment directory
- The reference implementation should not be shared initially but available if participants get stuck
- Include detailed comments in reference code explaining design decisions and best practices

## Workshop Flow

### Module 1: Understanding the Pet Store Microservice
- Introduction to the application architecture
- Review of the design documentation
- Local setup and testing
- Exploration of code structure and dependencies
- Understanding deployment requirements

### Module 2: Experiencing AI Agents in Action
- Using Amazon Q CLI to analyze design documents
- Learning to craft effective prompts for infrastructure tasks
- Observing how the agent processes prompts and makes decisions
- Experiencing how the agent uses tools to accomplish tasks
- Seeing how the agent leverages knowledge from design documents
- Generating infrastructure code for EKS deployment as a practical exercise
- Documenting observations about agent behavior
- Reflecting on the agent's problem-solving approach

### Critical Transition: Reflecting on Agent Experiences
- Group discussion about observations from Module 2
- Identifying patterns in agent behavior
- Introduction to the agent concept (LLM loop + Tools + Knowledge)
- Connecting experiences to formal concepts
- Preparing to build custom agents

### Module 3: Building a Pet Store Agent with MCP and Prompt-Driven Development
- Introduction to MCP (Model Context Protocol)
- Overview of Rapid Assistant SDK
- Applying the agent architecture components learned
- Creating a Pet Store API client
- Defining MCP tools for Pet Store operations
- Building the MCP server
- Configuring Amazon Q CLI to use the custom MCP server
- Hands-on exercises with prompt-driven development

### Module 4: Build Your Own Agent - Customer Use Case Challenge
- Group formation (3-5 participants per group)
- Use case identification and selection
- Agent design with explicit identification of LLM loop, tools, and knowledge components
- Agent implementation
- Presentation preparation
- Group presentations (5 minutes per group + 2 minutes Q&A)
- Evaluation and feedback

### Advanced Topics (Optional)
- Implementing CI/CD pipelines
- Adding monitoring and observability
- Configuring auto-scaling
- Setting up disaster recovery
- Implementing security best practices

## Example Amazon Q CLI Prompts

### For Design Document Analysis
```
q "Analyze the design documents in the design_docs directory and summarize the key requirements for containerization and deployment"
```

### For Infrastructure Code Generation
```
q "Based on the application requirements in design_docs/deployment_requirements.md, create a Dockerfile for the Pet Store application"
```

```
q "Create Kubernetes deployment and service manifests for the Pet Store application based on the architecture described in design_docs/architecture.md"
```

```
q "Generate Terraform code to provision an EKS cluster that meets the requirements in design_docs/deployment_requirements.md"
```

### For Agent Development
```
q "Design a tool definition for listing pets in a store using the Rapid Assistant SDK"
```

```
q "How can I improve the search_pets tool to handle case sensitivity and partial matches better?"
```

```
q "Help me create an MCP server using Rapid Assistant SDK that exposes the Pet Store API operations as tools"
```

### For Agent Interaction
```
q "Show me all the pets in the store"
```

```
q "Add a new dog named Max that's 3 years old with a price of $500"
```

## Preparation Checklist
- Test the Pet Store application to ensure it runs locally
- Validate that the design documentation provides sufficient context for Amazon Q CLI
- Test example Amazon Q CLI prompts to ensure they produce expected results
- Create checkpoints throughout the workshop for participants to validate their progress
- Prepare guided discovery questions for Module 2
- Create reflection prompts for the critical transition
- Test the MCP server implementation

## Workshop Extensions
- Multi-region deployment
- Blue-green deployment strategies
- Integration with additional AWS services
- Setting up monitoring with CloudWatch and Prometheus
- Implementing automated backup and recovery procedures
- Building specialized agents for different business domains
- Creating agent networks that collaborate to solve complex problems
- Implementing agent memory and context management
- Developing agents that can learn from user interactions
