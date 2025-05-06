"""
Pet Service - Business logic for pet operations
"""
from src.models.pet import Pet
from src.utils.database import get_session, close_session

class PetService:
    """Service class for pet operations"""
    
    @staticmethod
    def get_all_pets(status=None):
        """Get all pets, optionally filtered by status"""
        session = get_session()
        try:
            query = session.query(Pet)
            if status:
                query = query.filter(Pet.status == status)
            pets = query.all()
            return [pet.to_dict() for pet in pets]
        finally:
            close_session(session)
    
    @staticmethod
    def get_pet_by_id(pet_id):
        """Get a pet by its ID"""
        session = get_session()
        try:
            pet = session.query(Pet).filter(Pet.id == pet_id).first()
            return pet.to_dict() if pet else None
        finally:
            close_session(session)
    
    @staticmethod
    def create_pet(pet_data):
        """Create a new pet"""
        session = get_session()
        try:
            pet = Pet(
                name=pet_data['name'],
                species=pet_data['species'],
                breed=pet_data.get('breed'),
                age=pet_data.get('age'),
                price=pet_data.get('price', 0.0),
                status=pet_data.get('status', 'available')
            )
            session.add(pet)
            session.commit()
            return pet.to_dict()
        finally:
            close_session(session)
    
    @staticmethod
    def update_pet(pet_id, pet_data):
        """Update an existing pet"""
        session = get_session()
        try:
            pet = session.query(Pet).filter(Pet.id == pet_id).first()
            if not pet:
                return None
            
            # Update pet attributes
            for key, value in pet_data.items():
                if hasattr(pet, key):
                    setattr(pet, key, value)
            
            session.commit()
            return pet.to_dict()
        finally:
            close_session(session)
    
    @staticmethod
    def delete_pet(pet_id):
        """Delete a pet"""
        session = get_session()
        try:
            pet = session.query(Pet).filter(Pet.id == pet_id).first()
            if not pet:
                return False
            
            session.delete(pet)
            session.commit()
            return True
        finally:
            close_session(session)
