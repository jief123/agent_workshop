# Pet Store Data Model

## Overview

The Pet Store application uses a simple data model to represent pets in the store inventory. This document describes the database schema, entity relationships, and data validation rules.

## Entity Relationship Diagram

The current implementation includes a single entity: `Pet`. In a more complex version, additional entities such as `Category`, `Order`, and `Customer` would be included.

```
┌───────────────────────┐
│          Pet          │
├───────────────────────┤
│ id: Integer (PK)      │
│ name: String          │
│ species: String       │
│ breed: String         │
│ age: Float            │
│ price: Float          │
│ status: String        │
└───────────────────────┘
```

## Database Schema

### Pet Table

The `pets` table stores information about each pet in the inventory.

| Column  | Type    | Constraints       | Description                           |
|---------|---------|-------------------|---------------------------------------|
| id      | Integer | Primary Key, Auto | Unique identifier for the pet         |
| name    | String  | Not Null         | Name of the pet                       |
| species | String  | Not Null         | Species of the pet (e.g., Dog, Cat)   |
| breed   | String  | Nullable         | Breed of the pet within its species   |
| age     | Float   | Nullable         | Age of the pet in years               |
| price   | Float   | Not Null         | Price of the pet in USD               |
| status  | String  | Default: available | Status of the pet in the inventory    |

## Object Models

### Pet Model

The `Pet` class represents a pet in the inventory and maps to the `pets` table in the database.

```python
class Pet(Base):
    __tablename__ = 'pets'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False)
    species = Column(String(50), nullable=False)
    breed = Column(String(50))
    age = Column(Float)
    price = Column(Float, nullable=False)
    status = Column(String, default=PetStatus.AVAILABLE.value)
```

### Pet Status Enum

The `PetStatus` enum defines the possible status values for a pet:

```python
class PetStatus(enum.Enum):
    AVAILABLE = "available"
    PENDING = "pending"
    SOLD = "sold"
```

## Data Validation Rules

The following validation rules are applied to pet data:

1. **Name**: Required, maximum length of 50 characters
2. **Species**: Required, maximum length of 50 characters
3. **Breed**: Optional, maximum length of 50 characters
4. **Age**: Optional, must be a positive number
5. **Price**: Required, must be a non-negative number
6. **Status**: Must be one of the defined status values (available, pending, sold)

## Sample Data

Below is sample data for the `pets` table:

```
| id | name    | species | breed            | age | price | status    |
|----|---------|---------|------------------|-----|-------|-----------|
| 1  | Fluffy  | Cat     | Persian          | 2.0 | 100.0 | available |
| 2  | Buddy   | Dog     | Golden Retriever | 3.0 | 200.0 | available |
| 3  | Rex     | Dog     | German Shepherd  | 1.0 | 150.0 | pending   |
| 4  | Whiskers| Cat     | Siamese          | 1.5 | 120.0 | available |
| 5  | Max     | Dog     | Beagle           | 2.5 | 180.0 | sold      |
```

## Future Extensions

In a more complex version of the application, the data model could be extended to include:

1. **Categories**: To group pets by type (mammals, birds, reptiles, etc.)
2. **Tags**: To add searchable keywords to pets
3. **Images**: To store URLs or references to pet images
4. **Orders**: To track purchases of pets
5. **Customers**: To store information about pet buyers

These extensions would require additional tables and relationships in the database schema.
