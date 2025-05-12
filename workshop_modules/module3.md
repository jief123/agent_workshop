# Module 3: Building a Pet Store Agent with MCP and Rapid Assistant

## Overview

In this module, you will learn how to package the Pet Store API as an MCP (Model Context Protocol) server and build a custom agent using the Rapid Assistant SDK. This will enable Amazon Q CLI to directly interact with your Pet Store application through natural language, creating a powerful AI assistant specifically tailored for pet store operations.

## Learning Objectives

By the end of this module, you will:
- Understand the Model Context Protocol (MCP) and how it extends LLM capabilities
- Learn how to use Rapid Assistant SDK to build custom agents
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

## Implementation Steps

### Step 1: Set Up Your Development Environment

First, let's set up our development environment:

```bash
# Create a virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install required packages
pip install rapid-assistant requests flask
```

### Step 2: Define Pet Store API Client

Create a simple client to interact with the Pet Store API:

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
        
    def get_pet(self, pet_id):
        """Get details about a specific pet by ID."""
        response = requests.get(f"{self.base_url}/pets/{pet_id}")
        response.raise_for_status()
        return response.json()
        
    def create_pet(self, name, species, age, price):
        """Create a new pet in the store."""
        data = {
            "name": name,
            "species": species,
            "age": age,
            "price": price
        }
        response = requests.post(f"{self.base_url}/pets", json=data)
        response.raise_for_status()
        return response.json()
        
    def update_pet(self, pet_id, name=None, species=None, age=None, price=None):
        """Update an existing pet's information."""
        data = {}
        if name is not None:
            data["name"] = name
        if species is not None:
            data["species"] = species
        if age is not None:
            data["age"] = age
        if price is not None:
            data["price"] = price
            
        response = requests.put(f"{self.base_url}/pets/{pet_id}", json=data)
        response.raise_for_status()
        return response.json()
        
    def delete_pet(self, pet_id):
        """Delete a pet from the store."""
        response = requests.delete(f"{self.base_url}/pets/{pet_id}")
        response.raise_for_status()
        return True
```

### Step 3: Define MCP Tools

Now, let's define the tools that will be exposed through the MCP server:

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

@tool
def get_pet(pet_id: int) -> Dict:
    """Get details about a specific pet by ID."""
    return client.get_pet(pet_id)

@tool
def create_pet(name: str, species: str, age: int, price: float) -> Dict:
    """Create a new pet in the store."""
    return client.create_pet(name, species, age, price)

@tool
def update_pet(pet_id: int, name: Optional[str] = None, 
               species: Optional[str] = None, 
               age: Optional[int] = None, 
               price: Optional[float] = None) -> Dict:
    """Update an existing pet's information."""
    return client.update_pet(pet_id, name, species, age, price)

@tool
def delete_pet(pet_id: int) -> bool:
    """Delete a pet from the store."""
    return client.delete_pet(pet_id)

@tool
def search_pets(query: str) -> List[Dict]:
    """Search for pets based on name or species."""
    all_pets = client.list_pets()
    query = query.lower()
    return [
        pet for pet in all_pets 
        if query in pet["name"].lower() or query in pet["species"].lower()
    ]

@tool
def get_pet_statistics() -> Dict:
    """Get statistics about the pets in the store."""
    pets = client.list_pets()
    species_count = {}
    total_value = 0
    
    for pet in pets:
        species = pet["species"]
        species_count[species] = species_count.get(species, 0) + 1
        total_value += pet["price"]
        
    return {
        "total_pets": len(pets),
        "species_distribution": species_count,
        "total_value": total_value,
        "average_price": total_value / len(pets) if pets else 0
    }
```

### Step 4: Create the MCP Server

Now, let's create the MCP server that will expose these tools:

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
assistant.register_tool(create_pet)
assistant.register_tool(update_pet)
assistant.register_tool(delete_pet)
assistant.register_tool(search_pets)
assistant.register_tool(get_pet_statistics)

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

### Step 5: Run the MCP Server

Start your MCP server:

```bash
python pet_store_mcp_server.py
```

### Step 6: Configure Amazon Q CLI to Use Your MCP Server

Add your MCP server to Amazon Q CLI:

```bash
q mcp add pet-store http://localhost:8080
```

### Step 7: Interact with Your Pet Store Agent

Now you can use Amazon Q CLI to interact with your Pet Store agent:

```bash
q "Show me all the pets in the store"
q "Add a new dog named Max that's 3 years old with a price of $500"
q "What's the average price of all pets?"
q "Find all cats in the inventory"
q "Delete the pet with ID 5"
```

## Advanced Features

### Building Complex Workflows

You can enhance your Pet Store agent with more complex workflows:

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

You can extend your agent to integrate with AWS services:

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

@tool
def get_pet_image_url(pet_id: int) -> str:
    """Get the URL for a pet's image."""
    object_key = f"pets/{pet_id}.jpg"
    return f"https://{BUCKET_NAME}.s3.amazonaws.com/{object_key}"
```

## Workshop Exercises

### Exercise 1: Extend the Pet Store Agent

Add a new tool to the Pet Store agent that provides recommendations based on customer preferences:

1. Define the tool in `pet_store_tools.py`
2. Register the tool with the assistant
3. Test the tool using Amazon Q CLI

### Exercise 2: Add Authentication to Your MCP Server

Enhance your MCP server with basic authentication:

1. Modify the MCPServer configuration to require authentication
2. Update the Amazon Q CLI configuration to include credentials
3. Test the secure connection

### Exercise 3: Deploy Your MCP Server to AWS

Deploy your Pet Store MCP server to AWS:

1. Create a Dockerfile for your MCP server
2. Build and push the Docker image to Amazon ECR
3. Deploy the container to Amazon ECS or EKS
4. Configure Amazon Q CLI to use the deployed MCP server

## Conclusion

In this module, you learned how to:
- Package the Pet Store API as an MCP server
- Build a custom agent using Rapid Assistant SDK
- Create tools that interact with the Pet Store API
- Configure Amazon Q CLI to use your custom MCP server
- Implement complex workflows and integrations

You now have a powerful AI assistant specifically tailored for pet store operations, which can be extended with additional capabilities and integrations as needed.

## Next Steps

- Explore the advanced topics in the workshop
- Consider how you might apply these techniques to your own applications
- Experiment with more complex agent behaviors and workflows
- Integrate with additional AWS services for enhanced functionality
