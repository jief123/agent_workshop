"""
Tests for Pet Service
"""
import unittest
import os
import sys
sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from src.services.pet_service import PetService
from src.models.pet import Pet
from src.utils.database import init_db, get_session, close_session, Base, engine

class TestPetService(unittest.TestCase):
    """Test cases for PetService"""
    
    @classmethod
    def setUpClass(cls):
        """Set up test database"""
        # Use in-memory SQLite for tests
        os.environ['DATABASE_URL'] = 'sqlite:///:memory:'
        # Create tables
        Base.metadata.create_all(engine)
    
    def setUp(self):
        """Set up test data before each test"""
        self.session = get_session()
        # Add test pets
        pets = [
            Pet(name="Fluffy", species="Cat", breed="Persian", age=2, price=100.0),
            Pet(name="Buddy", species="Dog", breed="Golden Retriever", age=3, price=200.0),
            Pet(name="Rex", species="Dog", breed="German Shepherd", age=1, price=150.0)
        ]
        for pet in pets:
            self.session.add(pet)
        self.session.commit()
    
    def tearDown(self):
        """Clean up after each test"""
        # Delete all pets
        self.session.query(Pet).delete()
        self.session.commit()
        close_session(self.session)
    
    def test_get_all_pets(self):
        """Test getting all pets"""
        pets = PetService.get_all_pets()
        self.assertEqual(len(pets), 3)
    
    def test_get_pet_by_id(self):
        """Test getting a pet by ID"""
        # Get the first pet
        first_pet = self.session.query(Pet).first()
        pet = PetService.get_pet_by_id(first_pet.id)
        self.assertIsNotNone(pet)
        self.assertEqual(pet['name'], "Fluffy")
    
    def test_create_pet(self):
        """Test creating a new pet"""
        pet_data = {
            'name': 'Whiskers',
            'species': 'Cat',
            'breed': 'Siamese',
            'age': 1,
            'price': 120.0
        }
        pet = PetService.create_pet(pet_data)
        self.assertIsNotNone(pet)
        self.assertEqual(pet['name'], 'Whiskers')
        
        # Verify pet was added to database
        pets = PetService.get_all_pets()
        self.assertEqual(len(pets), 4)
    
    def test_update_pet(self):
        """Test updating a pet"""
        # Get the first pet
        first_pet = self.session.query(Pet).first()
        
        # Update the pet
        updated_data = {
            'name': 'Fluffy Jr.',
            'price': 150.0
        }
        pet = PetService.update_pet(first_pet.id, updated_data)
        self.assertIsNotNone(pet)
        self.assertEqual(pet['name'], 'Fluffy Jr.')
        self.assertEqual(pet['price'], 150.0)
    
    def test_delete_pet(self):
        """Test deleting a pet"""
        # Get the first pet
        first_pet = self.session.query(Pet).first()
        
        # Delete the pet
        success = PetService.delete_pet(first_pet.id)
        self.assertTrue(success)
        
        # Verify pet was deleted
        pets = PetService.get_all_pets()
        self.assertEqual(len(pets), 2)

if __name__ == '__main__':
    unittest.main()
