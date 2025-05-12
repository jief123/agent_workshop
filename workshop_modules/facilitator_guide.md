# Workshop Facilitator Guide

This guide provides instructions and tips for facilitators running the "IT Ops Acceleration with Amazon Q CLI" workshop.

## Workshop Overview

This workshop demonstrates how to use Amazon Q CLI and other AI agents to accelerate IT operations tasks. Participants will:
1. Understand a Pet Store microservice application
2. Transform it for deployment on AWS EKS using Amazon Q CLI
3. Build a custom Pet Store agent using MCP and Rapid Assistant SDK
4. Work in groups to develop their own agents for real-world use cases

## Workshop Timeline (Full Day)

| Time | Activity |
|------|----------|
| 9:00 - 9:30 | Welcome and Introduction |
| 9:30 - 10:30 | Module 1: Understanding the Pet Store Microservice |
| 10:30 - 10:45 | Break |
| 10:45 - 12:15 | Module 2: Transforming the Application for EKS |
| 12:15 - 13:15 | Lunch |
| 13:15 - 14:45 | Module 3: Building a Pet Store Agent with MCP and Rapid Assistant |
| 14:45 - 15:00 | Break |
| 15:00 - 16:00 | Module 4: Build Your Own Agent - Development Time |
| 16:00 - 16:45 | Module 4: Group Presentations |
| 16:45 - 17:00 | Wrap-up and Q&A |

## Workshop Timeline (Half Day)

| Time | Activity |
|------|----------|
| 9:00 - 9:15 | Welcome and Introduction |
| 9:15 - 10:00 | Module 1: Understanding the Pet Store Microservice |
| 10:00 - 10:45 | Module 3: Building a Pet Store Agent with MCP and Rapid Assistant |
| 10:45 - 11:00 | Break |
| 11:00 - 11:45 | Module 4: Build Your Own Agent - Development Time |
| 11:45 - 12:30 | Module 4: Group Presentations |
| 12:30 - 12:45 | Wrap-up and Q&A |

## Pre-workshop Setup

### Environment Setup

1. Ensure all participants have:
   - AWS account with appropriate permissions
   - AWS CLI configured
   - Amazon Q CLI installed
   - Python 3.8+ installed
   - Docker installed
   - kubectl installed
   - Git installed

2. Prepare workshop materials:
   - Clone the workshop repository for each participant
   - Ensure the Pet Store application runs locally
   - Test all example Amazon Q CLI prompts
   - Verify the reference deployment works

### Room Setup

1. Arrange tables for group work (4-5 participants per table)
2. Ensure good Wi-Fi connectivity
3. Provide power outlets for all participants
4. Set up a projector and screen
5. Prepare whiteboard or flip charts for group discussions

## Module-by-Module Facilitation Guide

### Welcome and Introduction

1. Introduce yourself and the workshop team
2. Explain the workshop objectives and agenda
3. Provide an overview of Amazon Q CLI and its capabilities
4. Explain the workshop format and expectations
5. Help participants with any setup issues

### Module 1: Understanding the Pet Store Microservice

**Key Points to Cover:**
- Application architecture and components
- API endpoints and functionality
- Database structure and data model
- Running the application locally
- Design documentation overview

**Potential Issues and Solutions:**
- **Issue**: Participants can't run the application locally
  - **Solution**: Ensure Python environment is set up correctly, check for missing dependencies
- **Issue**: Database initialization fails
  - **Solution**: Check file permissions, ensure SQLite is available

**Checkpoints:**
- Participants can run the application locally
- Participants can access the API endpoints
- Participants understand the application architecture

### Module 2: Transforming the Application for EKS

**Key Points to Cover:**
- Crafting effective prompts for Amazon Q CLI
- Containerization with Docker
- Kubernetes concepts and manifests
- Terraform for infrastructure as code
- Best practices for EKS deployment

**Potential Issues and Solutions:**
- **Issue**: Amazon Q CLI generates incorrect code
  - **Solution**: Show how to refine prompts for better results
- **Issue**: Docker build fails
  - **Solution**: Check Dockerfile syntax, ensure dependencies are available
- **Issue**: Terraform validation errors
  - **Solution**: Review error messages, fix syntax issues

**Checkpoints:**
- Participants have a working Dockerfile
- Participants have valid Kubernetes manifests
- Participants have working Terraform code

### Module 3: Building a Pet Store Agent with MCP and Rapid Assistant

**Key Points to Cover:**
- MCP concepts and benefits
- Rapid Assistant SDK overview
- Tool definition and implementation
- MCP server setup and configuration
- Amazon Q CLI integration with MCP
- Advanced features and workflows

**Potential Issues and Solutions:**
- **Issue**: MCP server fails to start
  - **Solution**: Check port conflicts, ensure dependencies are installed
- **Issue**: Tools don't work as expected
  - **Solution**: Debug tool implementation, check input/output types
- **Issue**: Amazon Q CLI can't connect to MCP server
  - **Solution**: Check network connectivity, verify server URL

**Checkpoints:**
- Participants have a running MCP server
- Participants can define and implement tools
- Participants can use Amazon Q CLI with their MCP server

### Module 4: Build Your Own Agent - Customer Use Case Challenge

**Key Points to Cover:**
- Group formation and use case selection
- Agent design principles
- Implementation strategies
- Presentation preparation
- Evaluation criteria

**Facilitation Tips:**
- Circulate among groups to provide guidance
- Help groups scope their projects appropriately
- Encourage creativity and practical applications
- Keep groups on schedule
- Ensure all group members participate

**Presentation Management:**
- Strictly enforce the 5-minute time limit
- Use a timer visible to presenters
- Prepare discussion questions for each presentation
- Encourage constructive feedback from other groups

## Common Questions and Answers

### Amazon Q CLI

**Q: How does Amazon Q CLI differ from ChatGPT or other LLMs?**
A: Amazon Q CLI is specifically designed for AWS and IT operations tasks, with deep integration with AWS services and the ability to execute commands directly in your environment.

**Q: Can Amazon Q CLI access my AWS resources?**
A: Yes, Amazon Q CLI can use your AWS credentials to interact with AWS services, but only with your explicit permission and within the limits of your IAM permissions.

### MCP and Rapid Assistant

**Q: What is the difference between MCP and other agent frameworks?**
A: MCP is an open protocol specifically designed for extending LLM capabilities with custom tools and context. It provides a standardized way for LLMs to interact with external systems.

**Q: Is Rapid Assistant production-ready?**
A: Rapid Assistant is designed for building production-quality agents, but as with any technology, you should thoroughly test and secure your implementation before using it in production.

### Workshop Technical Issues

**Q: What if Amazon Q CLI doesn't generate the expected code?**
A: Try refining your prompt with more specific instructions or context. You can also break down complex tasks into smaller, more focused prompts.

**Q: What if the MCP server crashes?**
A: Check the error messages for clues about what went wrong. Common issues include port conflicts, missing dependencies, or syntax errors in tool implementations.

## Post-Workshop

1. Collect feedback from participants
2. Share additional resources and documentation
3. Provide contact information for follow-up questions
4. Share the workshop repository for continued learning
5. Encourage participants to apply what they've learned in their organizations

## Resources

- [Amazon Q CLI Documentation](https://aws.amazon.com/q/)
- [MCP Protocol Specification](https://github.com/aws-samples/mcp-specification)
- [Rapid Assistant Documentation](https://docs.rapid-assistant.example.com)
- [AWS EKS Documentation](https://aws.amazon.com/eks/)
- [Terraform Documentation](https://www.terraform.io/docs)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)
