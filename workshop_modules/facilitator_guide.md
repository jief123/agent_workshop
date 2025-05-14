# Workshop Facilitator Guide

This guide provides instructions and tips for facilitators running the "IT Ops Acceleration with AI Agents" workshop.

## Workshop Philosophy: Experience Before Theory

This workshop follows an experiential learning approach where participants first experience working with AI agents before learning the formal concepts. **Do not introduce agent theory at the beginning**. Instead, let participants discover the capabilities through hands-on experience in Modules 1-2, then help them reflect on and conceptualize their experiences at the beginning of Module 3.

## Workshop Overview

This workshop demonstrates how to leverage AI agents for IT operations tasks through two complementary approaches:
1. First experiencing AI agents through hands-on use (Modules 1-2)
2. Then building custom agents based on that experience (Modules 3-4)

## Workshop Timeline (Full Day)

| Time | Activity |
|------|----------|
| 8:30 - 9:00 | Registration and Setup |
| 9:00 - 10:30 | Module 1: Understanding the Pet Store Microservice |
| 10:30 - 10:45 | Break |
| 10:45 - 12:45 | Module 2: Experiencing Amazon Q CLI for Infrastructure Tasks |
| 12:45 - 13:30 | Lunch |
| 13:30 - 14:00 | **Critical Transition: Reflecting on Agent Experiences** |
| 14:00 - 15:00 | Module 3: Building a Pet Store Agent with MCP and Prompt-Driven Development |
| 15:00 - 15:15 | Break |
| 15:15 - 16:45 | Module 4: Build Your Own Agent - Development and Presentations |
| 16:45 - 17:00 | Wrap-up and Q&A |


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
3. Provide a basic overview of Amazon Q CLI as a tool for IT operations
4. Explain the workshop format and expectations
5. Help participants with any setup issues
6. **Important**: Do NOT introduce agent theory or components yet

### Module 1: Understanding the Pet Store Microservice

**Key Points to Cover:**
- How to interact with Amazon Q CLI
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

### Module 2: Experiencing Amazon Q CLI for Infrastructure Tasks

**Key Points to Cover:**
- Crafting effective prompts for infrastructure tasks
- Using Amazon Q CLI to generate deployment code
- Reviewing and refining the generated code

**Guided Discovery Activities:**
- Have participants document interesting observations about Amazon Q CLI's behavior
- Ask thought-provoking questions that direct attention to key capabilities without naming them:
  - "What did you notice about how Amazon Q approached this problem?"
  - "How did Amazon Q use the information from the design documents?"
  - "What actions did Amazon Q take to accomplish this task?"
  - "How did Amazon Q respond when you refined your prompt?"

**Potential Issues and Solutions:**
- **Issue**: Amazon Q CLI generates incorrect code
  - **Solution**: Show how to refine prompts for better results
- **Issue**: Docker build fails
  - **Solution**: Check Dockerfile syntax, ensure dependencies are available
- **Issue**: Terraform validation errors
  - **Solution**: Review error messages, fix syntax issues

**Checkpoints:**
- Participants can effectively interact with Amazon Q CLI
- Participants have generated working infrastructure code
- Participants have documented their observations about Amazon Q CLI's behavior

### Critical Transition: Reflecting on Agent Experiences

This 30-minute session after lunch is the pivotal moment where you help participants connect their experiences to agent theory.

**Facilitation Approach:**
1. **Group Discussion** (15 minutes):
   - Ask: "What did you observe about how Amazon Q CLI worked?"
   - Ask: "What capabilities did Amazon Q CLI demonstrate?"
   - Ask: "How did Amazon Q CLI help you accomplish tasks?"
   - Document observations on a whiteboard or shared document

2. **Introduce Agent Concept** (15 minutes):
   - Now introduce the concept that an AI agent consists of three components:
     - **LLM Loop**: The reasoning and decision-making component
     - **Tools**: The capabilities that allow the agent to take actions
     - **Knowledge**: The information and context the agent can access
   - Connect these concepts directly to participants' experiences:
     - "When Amazon Q analyzed your problem and explained its thinking, that was the LLM loop in action"
     - "When Amazon Q created files, ran commands, or made AWS API calls, it was using tools"
     - "When Amazon Q referenced design documents or applied AWS best practices, it was leveraging knowledge"

3. **Bridge to Building Agents**:
   - Explain that in the next modules, they'll build their own agents with these same components
   - "Now that you've experienced how an agent works, you'll create your own with the same fundamental components"

### Module 3: Building a Pet Store Agent with MCP and Prompt-Driven Development

**Key Points to Cover:**
- Applying the agent architecture they've just learned about
- MCP concepts and benefits
- Rapid Assistant SDK overview
- Prompt-driven development methodology
- Tool definition and implementation
- MCP server setup and configuration
- Amazon Q CLI integration with MCP

**Connect to Previous Experience:**
- "You'll now create tools similar to what you saw Amazon Q using"
- "Your agent will need knowledge about the Pet Store API, just like Amazon Q needed knowledge about the application architecture"
- "The LLM loop will help your agent make decisions about which tools to use based on user requests"

**Prompt-Driven Development Pattern:**
- Requirements analysis using prompts
- Tool design through iterative prompting
- Implementation guidance with Amazon Q
- Testing and refinement with AI assistance
- Integration with existing systems

**Potential Issues and Solutions:**
- **Issue**: MCP server fails to start
  - **Solution**: Check port conflicts, ensure dependencies are installed
- **Issue**: Tools don't work as expected
  - **Solution**: Debug tool implementation, check input/output types
- **Issue**: Amazon Q CLI can't connect to MCP server
  - **Solution**: Check network connectivity, verify server URL

**Checkpoints:**
- Participants understand how to apply the agent components they experienced
- Participants have a running MCP server
- Participants can define and implement tools
- Participants can use Amazon Q CLI with their MCP server

### Module 4: Build Your Own Agent - Customer Use Case Challenge

**Key Points to Cover:**
- Group formation and use case selection
- Agent design principles (applying LLM loop + Tools + Knowledge)
- Implementation strategies
- Presentation preparation
- Evaluation criteria

**Facilitation Tips:**
- Circulate among groups to provide guidance
- Help groups scope their projects appropriately
- Encourage creativity and practical applications
- Keep groups on schedule
- Ensure all group members participate
- Remind groups to explicitly identify the three agent components in their designs

**Presentation Management:**
- Strictly enforce the 5-minute time limit
- Use a timer visible to presenters
- Prepare discussion questions for each presentation
- Encourage constructive feedback from other groups
- Ask each group to explain how their agent implements the three core components

## Common Questions and Answers

### AI Agent Architecture

**Q: What exactly makes something an "agent" versus just an AI tool?**
A: An agent combines reasoning (LLM loop), the ability to take actions (tools), and contextual information (knowledge) to autonomously work toward goals. Unlike simple tools that perform fixed functions, agents can adapt their approach based on the situation.

**Q: How do I know which tools my agent needs?**
A: Tools should be designed based on the specific actions your agent needs to take. Start by identifying the operations users will want to perform, then create tools that enable those operations.

**Q: How much knowledge should I provide to my agent?**
A: Provide enough context for the agent to make informed decisions, but avoid overwhelming it with irrelevant information. Focus on documentation, specifications, and examples relevant to the tasks.

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

### Prompt-Driven Development

**Q: How does prompt-driven development differ from traditional development?**
A: Prompt-driven development uses AI-generated code and designs through carefully crafted prompts, allowing for rapid iteration and exploration of solutions before committing to implementation.

**Q: What makes a good prompt for agent development?**
A: Good prompts are specific about the desired functionality, include context about the system, specify input/output requirements, and consider edge cases and error handling.

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
