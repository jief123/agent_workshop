# Module 3: Building a Pet Store Agent with MCP and Rapid Assistant

## Overview

In this module, you will learn how to package the Pet Store API as an MCP (Model Context Protocol) server and build a custom agent using the Rapid Assistant SDK. You'll apply prompt-driven development techniques to design and implement your agent, enabling Amazon Q CLI to directly interact with your Pet Store application through natural language.

## Learning Objectives

By the end of this module, you will:
- Understand the Model Context Protocol (MCP) and how it extends LLM capabilities
- Learn how to use Rapid Assistant SDK to build custom agents
- Apply prompt-driven development to design and implement agent tools
- Package the Pet Store API as an MCP server
- Create custom tools that interact with the Pet Store API
- Configure Amazon Q CLI to use your custom MCP server
- Build complex workflows for pet store operations

## Prerequisites

- Completed Module 1 and Module 2
- Pet Store application running locally or deployed to EKS
- Python 3.8+ installed
- Basic understanding of API concepts
- Amazon Q CLI installed and configured

## What is MCP?

The Model Context Protocol (MCP) is an open protocol that standardizes how applications provide context to Large Language Models (LLMs). MCP enables communication between LLMs like those powering Amazon Q and locally running MCP servers that provide additional tools and resources to extend the LLM's capabilities.

Key benefits of MCP:
- Extends LLM capabilities with custom tools
- Provides secure access to private data and systems
- Enables domain-specific AI assistants
- Allows for stateful interactions and complex workflows

## What is Rapid Assistant?

Rapid Assistant is an SDK designed to simplify the creation of AI assistants and agents. It provides a framework for:
- Defining custom tools that LLMs can use
- Building conversational workflows
- Managing context and state
- Implementing MCP servers
- Handling authentication and security

## Prompt-Driven Development for Agent Creation

Prompt-driven development is an approach that uses AI assistance throughout the agent development lifecycle. Instead of manually coding every aspect of your agent, you use carefully crafted prompts to generate designs, code, and tests, iteratively refining your agent's capabilities.

### The Prompt-Driven Development Cycle

1. **Requirements Analysis**: Use prompts to analyze use cases and identify needed capabilities
2. **Tool Design**: Generate tool definitions through prompts
3. **Implementation**: Use prompts to generate implementation code
4. **Testing & Refinement**: Test the tools and refine through additional prompts
5. **Integration**: Integrate the tools into your MCP server

### Example Prompts for Agent Development

For each stage of development, you can use specific types of prompts:

1. **Requirements Analysis**:
   ```
   q "Given the Pet Store API that manages pet inventory, what capabilities should my agent have to provide a complete interface for users?"
   ```

2. **Tool Design**:
   ```
   q "Design a tool definition for searching pets by attributes like species and age range, including appropriate parameters and error handling"
   ```

3. **Implementation**:
   ```
   q "Generate the Python code for implementing the search_pets_by_attributes tool using Rapid Assistant SDK"
   ```

4. **Testing & Refinement**:
   ```
   q "What edge cases should I test for the search_pets_by_attributes tool?"
   q "How can I improve the response format to make it more user-friendly?"
   ```

5. **Integration**:
   ```
   q "How should I integrate this tool with my existing Pet Store MCP server?"
   ```

## Implementation Steps Using Prompt-Driven Development

### Step 1: Set Up Your Development Environment

First, let's set up our development environment:

```bash
# Create a virtual environment
python -m venv venv
source venv/activate  # On Windows: venv\Scripts\activate

# Install required packages
pip install rapid-assistant requests flask
```

### Step 2: Define Requirements Using Amazon Q

Instead of manually defining what your agent should do, use Amazon Q to help identify the requirements:

```bash
q "I want to create an agent for a Pet Store API. The API has endpoints for listing, creating, updating, and deleting pets. What capabilities should my agent have, and what tools should I define?"
```

Amazon Q will provide you with a list of suggested tools and capabilities, which might include:
- Listing all pets
- Getting details about a specific pet
- Creating new pets
- Updating existing pets
- Deleting pets
- Searching for pets
- Getting statistics about the inventory

### Step 3: Design Pet Store API Client with Amazon Q

Use Amazon Q to help design your API client:

```bash
q "Help me design a Python client for a Pet Store API with the following endpoints:
- GET /pets - List all pets
- GET /pets/{id} - Get a specific pet
- POST /pets - Create a new pet
- PUT /pets/{id} - Update a pet
- DELETE /pets/{id} - Delete a pet

The client should handle errors appropriately and return JSON responses."
```

Based on Amazon Q's response, create your `pet_store_client.py` file:

```python
# pet_store_client.py
import requests

class PetStoreClient:
    def __init__(self, base_url="http://localhost:5000"):
        self.base_url = base_url
        
    def list_pets(self, limit=None):
        """List all pets in the store, with optional limit."""
        params = {"limit": limit} if limit else {}
        response = requests.get(f"{self.base_url}/pets", params=params)
        response.raise_for_status()
        return response.json()
        
    # Additional methods as suggested by Amazon Q
    # ...
```

### Step 4: Define MCP Tools Using Prompt-Driven Development

Instead of manually coding each tool, use Amazon Q to help design and implement them:

```bash
q "Design a tool definition for listing pets in a store using the Rapid Assistant SDK. The tool should accept an optional limit parameter and return a list of pets."
```

Based on Amazon Q's response, create your first tool:

```python
# pet_store_tools.py
from typing import Optional, List, Dict
from rapid_assistant import tool
from pet_store_client import PetStoreClient

# Initialize the client
client = PetStoreClient()

@tool
def list_pets(limit: Optional[int] = None) -> List[Dict]:
    """List all pets in the store, with optional limit."""
    return client.list_pets(limit)
```

Continue this process for each tool you want to create:

```bash
q "Design a tool definition for creating a new pet in the store. The tool should accept name, species, age, and price parameters."
```

Add the new tool to your file:

```python
@tool
def create_pet(name: str, species: str, age: int, price: float) -> Dict:
    """Create a new pet in the store."""
    return client.create_pet(name, species, age, price)
```

### Step 5: Create the MCP Server with Amazon Q's Help

Use Amazon Q to help you create the MCP server:

```bash
q "Help me create an MCP server using Rapid Assistant SDK that exposes the following tools for a Pet Store API:
- list_pets
- get_pet
- create_pet
- update_pet
- delete_pet
- search_pets
- get_pet_statistics"
```

Based on Amazon Q's response, create your MCP server:

```python
# pet_store_mcp_server.py
from rapid_assistant import RapidAssistant, MCPServer
from pet_store_tools import (
    list_pets, get_pet, create_pet, update_pet, 
    delete_pet, search_pets, get_pet_statistics
)

# Initialize the assistant
assistant = RapidAssistant(
    name="PetStoreAssistant",
    description="An assistant that helps manage a pet store inventory"
)

# Register tools
assistant.register_tool(list_pets)
assistant.register_tool(get_pet)
# Register other tools...

# Create MCP server
mcp_server = MCPServer(
    assistant=assistant,
    host="0.0.0.0",
    port=8080
)

if __name__ == "__main__":
    print("Starting Pet Store MCP Server on port 8080...")
    mcp_server.start()
```

### Step 6: Test and Refine Your Tools with Amazon Q

After implementing your tools, use Amazon Q to help test and refine them:

```bash
q "What edge cases should I test for the search_pets tool in my Pet Store agent?"
```

Based on Amazon Q's suggestions, improve your tools:

```bash
q "How can I improve the search_pets tool to handle case sensitivity, partial matches, and empty results better?"
```

### Step 7: Run the MCP Server

Start your MCP server:

```bash
python pet_store_mcp_server.py
```

### Step 8: Configure Amazon Q CLI to Use Your MCP Server

Add your MCP server to Amazon Q CLI:

```bash
q mcp add pet-store http://localhost:8080
```

### Step 9: Interact with Your Pet Store Agent

Now you can use Amazon Q CLI to interact with your Pet Store agent:

```bash
q "Show me all the pets in the store"
q "Add a new dog named Max that's 3 years old with a price of $500"
q "What's the average price of all pets?"
q "Find all cats in the inventory"
q "Delete the pet with ID 5"
```

## Advanced Features Using Prompt-Driven Development

### Building Complex Workflows

Use Amazon Q to help design more complex workflows for your agent:

```bash
q "Design a tool for a Pet Store agent that recommends pets based on customer preferences like budget, preferred species, and maximum age. Include the Python code using Rapid Assistant SDK."
```

Based on Amazon Q's response, implement the recommendation tool:

```python
@tool
def recommend_pet(budget: float, preferred_species: Optional[str] = None, 
                  max_age: Optional[int] = None) -> List[Dict]:
    """Recommend pets based on budget and preferences."""
    pets = client.list_pets()
    
    # Filter by budget
    pets = [pet for pet in pets if pet["price"] <= budget]
    
    # Filter by species if specified
    if preferred_species:
        pets = [pet for pet in pets if pet["species"].lower() == preferred_species.lower()]
    
    # Filter by age if specified
    if max_age is not None:
        pets = [pet for pet in pets if pet["age"] <= max_age]
    
    # Sort by best match (closest to budget)
    pets.sort(key=lambda pet: budget - pet["price"])
    
    return pets[:5]  # Return top 5 recommendations
```

### Integrating with AWS Services

Use Amazon Q to help integrate your agent with AWS services:

```bash
q "Help me extend my Pet Store agent with a tool that uploads pet images to S3. Include error handling and return the public URL of the uploaded image."
```

Based on Amazon Q's response, implement the AWS integration:

```python
import boto3
from botocore.exceptions import ClientError

s3 = boto3.client('s3')
BUCKET_NAME = 'pet-store-images'

@tool
def upload_pet_image(pet_id: int, image_path: str) -> str:
    """Upload a pet image to S3."""
    try:
        object_key = f"pets/{pet_id}.jpg"
        s3.upload_file(image_path, BUCKET_NAME, object_key)
        return f"https://{BUCKET_NAME}.s3.amazonaws.com/{object_key}"
    except ClientError as e:
        return f"Error uploading image: {str(e)}"
```

## Workshop Exercises

### Exercise 1: Extend the Pet Store Agent Using Prompt-Driven Development

Use Amazon Q to help you add a new tool to the Pet Store agent:

1. Define the requirements for a new tool:
   ```bash
   q "I want to add a tool to my Pet Store agent that provides discount recommendations based on inventory levels. What should this tool do and what parameters should it have?"
   ```

2. Design the tool using Amazon Q:
   ```bash
   q "Design a tool definition for calculating pet discounts based on inventory levels using Rapid Assistant SDK"
   ```

3. Implement the tool based on Amazon Q's guidance
4. Test and refine the tool with Amazon Q's help
5. Add the tool to your MCP server

### Exercise 2: Add Authentication to Your MCP Server

Use Amazon Q to help you add authentication to your MCP server:

```bash
q "How can I add basic authentication to my Pet Store MCP server using Rapid Assistant SDK?"
```

### Exercise 3: Deploy Your MCP Server to AWS

Use Amazon Q to help you deploy your Pet Store MCP server to AWS:

```bash
q "Help me create a Dockerfile for my Pet Store MCP server"
```

```bash
q "Generate a simple CI/CD workflow for deploying my Pet Store MCP server to AWS ECS"
```

## Conclusion

In this module, you learned how to:
- Apply prompt-driven development to agent creation
- Package the Pet Store API as an MCP server
- Build a custom agent using Rapid Assistant SDK
- Create tools that interact with the Pet Store API
- Configure Amazon Q CLI to use your custom MCP server
- Implement complex workflows and integrations

You now have a powerful AI assistant specifically tailored for pet store operations, which can be extended with additional capabilities and integrations as needed.

## Next Steps

- Explore the advanced topics in the workshop
- Consider how you might apply prompt-driven development to your own applications
- Experiment with more complex agent behaviors and workflows
- Integrate with additional AWS services for enhanced functionality
