# Module 4: Build Your Own Agent - Customer Use Case Challenge

## Overview

In this module, participants will apply what they've learned throughout the workshop to develop their own custom agents using MCP and Rapid Assistant SDK. Working in groups, you'll identify a real-world use case from your organization, design an agent solution, implement it, and present your work to the entire workshop.

## Learning Objectives

By the end of this module, you will:
- Apply MCP and Rapid Assistant concepts to real-world problems
- Design and implement a custom agent for a specific use case
- Work collaboratively in a team environment
- Present and explain your agent solution to peers
- Learn from other teams' approaches and implementations

## Workshop Format

- **Group Formation**: 3-5 participants per group
- **Agent Development**: 1 hour
- **Presentations**: 5 minutes per group
- **Q&A and Feedback**: 2 minutes per group

## Group Challenge Instructions

### Step 1: Form Groups (10 minutes)

1. Form groups of 3-5 participants
2. Introduce yourselves and share your backgrounds
3. Discuss potential use cases from your organizations
4. Select one use case to implement

### Step 2: Design Your Agent (15 minutes)

1. Define the problem statement clearly
2. Identify the key capabilities your agent needs
3. Design the tools your agent will expose
4. Sketch the architecture of your solution
5. Create a simple implementation plan

Use this template to document your design:

```markdown
# Agent Design Document

## Problem Statement
[Describe the problem your agent will solve]

## Target Users
[Who will use this agent?]

## Key Capabilities
- [Capability 1]
- [Capability 2]
- [Capability 3]

## Tools Design
- Tool 1: [Name] - [Purpose] - [Inputs/Outputs]
- Tool 2: [Name] - [Purpose] - [Inputs/Outputs]
- Tool 3: [Name] - [Purpose] - [Inputs/Outputs]

## Architecture
[Brief description or simple diagram]

## Implementation Plan
1. [Step 1]
2. [Step 2]
3. [Step 3]
```

### Step 3: Implement Your Agent (45 minutes)

1. Set up your development environment
2. Create the necessary tool definitions
3. Implement the MCP server
4. Test your agent with Amazon Q CLI
5. Refine and improve your implementation

### Step 4: Prepare Your Presentation (10 minutes)

Prepare a 5-minute presentation that covers:
1. The problem you're solving
2. Your agent's key capabilities
3. Technical implementation highlights
4. A live demo of your agent in action
5. Challenges faced and lessons learned

### Step 5: Group Presentations (5 minutes per group)

Each group will present their agent solution to the workshop:
- 5 minutes for presentation and demo
- 2 minutes for Q&A and feedback

## Use Case Ideas

If your group is having trouble identifying a use case, consider one of these options:

### 1. IT Support Agent
Create an agent that helps IT support staff diagnose and resolve common issues:
- Tool to check system status
- Tool to restart services
- Tool to look up error codes
- Tool to generate troubleshooting steps

### 2. Cloud Cost Optimization Agent
Build an agent that helps identify cost optimization opportunities:
- Tool to analyze AWS cost explorer data
- Tool to identify underutilized resources
- Tool to recommend rightsizing options
- Tool to estimate potential savings

### 3. Development Workflow Agent
Develop an agent that assists with software development workflows:
- Tool to create JIRA tickets
- Tool to check PR status
- Tool to run tests
- Tool to generate release notes

### 4. Infrastructure Monitoring Agent
Create an agent that helps monitor and manage infrastructure:
- Tool to check service health
- Tool to view recent alerts
- Tool to analyze logs
- Tool to scale resources

### 5. Documentation Assistant
Build an agent that helps create and maintain documentation:
- Tool to generate documentation templates
- Tool to extract API specifications
- Tool to validate documentation against code
- Tool to publish documentation updates

## Implementation Tips

### Setting Up Your Environment

```bash
# Create a project directory
mkdir my-agent-project
cd my-agent-project

# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install required packages
pip install rapid-assistant requests flask
```

### Basic Agent Template

```python
# agent.py
from rapid_assistant import RapidAssistant, MCPServer, tool
from typing import Dict, List, Optional

# Define your tools
@tool
def example_tool(param1: str, param2: Optional[int] = None) -> Dict:
    """
    Description of what this tool does.
    
    Args:
        param1: Description of param1
        param2: Description of param2
    
    Returns:
        Dictionary with results
    """
    # Tool implementation
    result = {"param1": param1}
    if param2 is not None:
        result["param2"] = param2
    return result

# Initialize the assistant
assistant = RapidAssistant(
    name="MyCustomAgent",
    description="Description of what my agent does"
)

# Register tools
assistant.register_tool(example_tool)

# Create MCP server
mcp_server = MCPServer(
    assistant=assistant,
    host="0.0.0.0",
    port=8080
)

if __name__ == "__main__":
    print("Starting My Custom Agent MCP Server on port 8080...")
    mcp_server.start()
```

### Testing Your Agent

```bash
# Start your MCP server
python agent.py

# In another terminal, add your MCP server to Amazon Q CLI
q mcp add my-agent http://localhost:8080

# Test your agent
q "Use my custom agent to [describe what you want to do]"
```

## Evaluation Criteria

Presentations will be evaluated based on:
1. **Innovation**: How creative and useful is the agent?
2. **Technical Implementation**: How well is the agent implemented?
3. **User Experience**: How intuitive and effective is the agent interaction?
4. **Presentation Quality**: How clear and engaging is the presentation?
5. **Demo Effectiveness**: How well does the live demo showcase the agent's capabilities?

## Resources

- [Rapid Assistant Documentation](https://docs.rapid-assistant.example.com)
- [MCP Protocol Specification](https://github.com/aws-samples/mcp-specification)
- [Amazon Q CLI Documentation](https://aws.amazon.com/q/)
- [Example Agents Repository](https://github.com/example/mcp-agent-examples)

## Conclusion

This module gives you the opportunity to apply everything you've learned in a practical, hands-on challenge. By designing and implementing your own agent, you'll gain valuable experience that you can take back to your organization. The group presentations provide a chance to learn from others and see different approaches to agent development.

Remember, the goal is not just to create a working agent but to think about how this technology can solve real problems in your organization. Good luck, and have fun building your agents!
