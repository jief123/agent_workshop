#!/usr/bin/env python3
"""
Test script for Pet Store API
Tests all CRUD operations: Create, Read, Update, Delete
"""
import requests
import json
import sys

BASE_URL = "http://localhost:8080/api/v1"

def print_response(response, operation):
    """Print formatted response"""
    print(f"\n=== {operation} ===")
    print(f"Status Code: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}")
    print("=" * 50)

def test_health_endpoint():
    """Test the health endpoint"""
    response = requests.get(f"{BASE_URL}/health")
    print_response(response, "Health Check")
    return response.status_code == 200

def create_pet():
    """Create a new pet"""
    new_pet = {
        "name": "TestPet",
        "species": "Dog",
        "breed": "Test Breed",
        "age": 3,
        "price": 150.0,
        "status": "available"
    }
    
    response = requests.post(f"{BASE_URL}/pets", json=new_pet)
    print_response(response, "Create Pet")
    
    if response.status_code == 201:
        return response.json()["id"]
    else:
        print("Failed to create pet")
        return None

def get_all_pets():
    """Get all pets"""
    response = requests.get(f"{BASE_URL}/pets")
    print_response(response, "Get All Pets")
    return response.status_code == 200

def get_pet_by_id(pet_id):
    """Get a specific pet by ID"""
    response = requests.get(f"{BASE_URL}/pets/{pet_id}")
    print_response(response, f"Get Pet by ID: {pet_id}")
    return response.status_code == 200

def update_pet(pet_id):
    """Update a pet"""
    update_data = {
        "name": "UpdatedTestPet",
        "price": 200.0,
        "status": "pending"
    }
    
    response = requests.put(f"{BASE_URL}/pets/{pet_id}", json=update_data)
    print_response(response, f"Update Pet: {pet_id}")
    return response.status_code == 200

def delete_pet(pet_id):
    """Delete a pet"""
    response = requests.delete(f"{BASE_URL}/pets/{pet_id}")
    print_response(response, f"Delete Pet: {pet_id}")
    return response.status_code == 200

def run_all_tests():
    """Run all API tests"""
    tests_passed = 0
    tests_failed = 0
    
    print("\n🔍 Starting Pet Store API Tests...\n")
    
    # Test health endpoint
    if test_health_endpoint():
        print("✅ Health check passed")
        tests_passed += 1
    else:
        print("❌ Health check failed")
        tests_failed += 1
    
    # Create a new pet
    pet_id = create_pet()
    if pet_id:
        print(f"✅ Create pet passed (ID: {pet_id})")
        tests_passed += 1
    else:
        print("❌ Create pet failed")
        tests_failed += 1
        # If we can't create a pet, we can't continue with other tests
        print("\n❌ Cannot continue with other tests as pet creation failed")
        return
    
    # Get all pets
    if get_all_pets():
        print("✅ Get all pets passed")
        tests_passed += 1
    else:
        print("❌ Get all pets failed")
        tests_failed += 1
    
    # Get pet by ID
    if get_pet_by_id(pet_id):
        print(f"✅ Get pet by ID passed (ID: {pet_id})")
        tests_passed += 1
    else:
        print(f"❌ Get pet by ID failed (ID: {pet_id})")
        tests_failed += 1
    
    # Update pet
    if update_pet(pet_id):
        print(f"✅ Update pet passed (ID: {pet_id})")
        tests_passed += 1
    else:
        print(f"❌ Update pet failed (ID: {pet_id})")
        tests_failed += 1
    
    # Delete pet
    if delete_pet(pet_id):
        print(f"✅ Delete pet passed (ID: {pet_id})")
        tests_passed += 1
    else:
        print(f"❌ Delete pet failed (ID: {pet_id})")
        tests_failed += 1
    
    # Print summary
    print(f"\n📊 Test Summary: {tests_passed} passed, {tests_failed} failed")
    
    if tests_failed == 0:
        print("\n🎉 All tests passed successfully!")
    else:
        print(f"\n⚠️ {tests_failed} tests failed!")

if __name__ == "__main__":
    run_all_tests()
