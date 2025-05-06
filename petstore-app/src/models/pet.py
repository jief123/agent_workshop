"""
Pet Model - Defines the Pet entity and its database schema
"""
from sqlalchemy import Column, Integer, String, Float, Enum
import enum
from src.utils.database import Base

class PetStatus(enum.Enum):
    AVAILABLE = "available"
    PENDING = "pending"
    SOLD = "sold"

class Pet(Base):
    """Pet entity representing an animal in the pet store inventory"""
    __tablename__ = 'pets'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(50), nullable=False)
    species = Column(String(50), nullable=False)
    breed = Column(String(50))
    age = Column(Float)
    price = Column(Float, nullable=False)
    status = Column(String, default=PetStatus.AVAILABLE.value)
    
    def __init__(self, name, species, breed=None, age=None, price=0.0, status=PetStatus.AVAILABLE.value):
        self.name = name
        self.species = species
        self.breed = breed
        self.age = age
        self.price = price
        self.status = status
    
    def to_dict(self):
        """Convert Pet object to dictionary"""
        return {
            'id': self.id,
            'name': self.name,
            'species': self.species,
            'breed': self.breed,
            'age': self.age,
            'price': self.price,
            'status': self.status
        }
