"""
Pet Controller - Handles HTTP requests for pet operations
"""
from flask import Blueprint, request, jsonify
from src.services.pet_service import PetService

pet_bp = Blueprint('pet_bp', __name__)

@pet_bp.route('/pets', methods=['GET'])
def get_pets():
    """Get all pets, optionally filtered by status"""
    status = request.args.get('status')
    pets = PetService.get_all_pets(status)
    return jsonify(pets)

@pet_bp.route('/pets/<int:pet_id>', methods=['GET'])
def get_pet(pet_id):
    """Get a pet by ID"""
    pet = PetService.get_pet_by_id(pet_id)
    if not pet:
        return jsonify({"error": "Pet not found"}), 404
    return jsonify(pet)

@pet_bp.route('/pets', methods=['POST'])
def create_pet():
    """Create a new pet"""
    if not request.json:
        return jsonify({"error": "Invalid request data"}), 400
    
    required_fields = ['name', 'species']
    for field in required_fields:
        if field not in request.json:
            return jsonify({"error": f"Missing required field: {field}"}), 400
    
    pet = PetService.create_pet(request.json)
    return jsonify(pet), 201

@pet_bp.route('/pets/<int:pet_id>', methods=['PUT'])
def update_pet(pet_id):
    """Update an existing pet"""
    if not request.json:
        return jsonify({"error": "Invalid request data"}), 400
    
    pet = PetService.update_pet(pet_id, request.json)
    if not pet:
        return jsonify({"error": "Pet not found"}), 404
    return jsonify(pet)

@pet_bp.route('/pets/<int:pet_id>', methods=['DELETE'])
def delete_pet(pet_id):
    """Delete a pet"""
    success = PetService.delete_pet(pet_id)
    if not success:
        return jsonify({"error": "Pet not found"}), 404
    return jsonify({"message": "Pet deleted successfully"})
