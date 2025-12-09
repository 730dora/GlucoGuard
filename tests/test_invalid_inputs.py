import pytest
from app import app
from main import app
from backend import app

@pytest.fixture
def client():
    app.testing = True
    with app.test_client() as client:
        yield client


def test_missing_field(client):
    data = {
        "glucose": 120,
        "bmi": 23.5,
        # "age" missing here
        "systolic": 120,
        "diastolic": 80,
        "insulin": 90,
        "skinThickness": 20,
        "gender": "female"
    }
    response = client.post('/predict', json=data)
    assert response.status_code in (400, 422)


def test_invalid_type_string(client):
    data = {
        "glucose": "hello",
        "bmi": 23.5,
        "age": 30,
        "systolic": 120,
        "diastolic": 80,
        "insulin": 90,
        "skinThickness": 20,
        "gender": "female"
    }
    response = client.post('/predict', json=data)
    assert response.status_code in (400, 422)


def test_negative_values(client):
    data = {
        "glucose": -20,
        "bmi": -5,
        "age": -10,
        "systolic": 120,
        "diastolic": 80,
        "insulin": 90,
        "skinThickness": 20,
        "gender": "male"
    }
    response = client.post('/predict', json=data)
    assert response.status_code in (400, 422)


def test_empty_body(client):
    response = client.post('/predict', json={})
    assert response.status_code in (400, 422)


def test_invalid_gender_value(client):
    data = {
        "glucose": 100,
        "bmi": 20,
        "age": 25,
        "systolic": 110,
        "diastolic": 70,
        "insulin": 90,
        "skinThickness": 20,
        "gender": "dragon"
    }
    response = client.post('/predict', json=data)
    assert response.status_code in (400, 422)


def test_extreme_values(client):
    data = {
        "glucose": 999999,
        "bmi": 500,
        "age": 999,
        "systolic": 1000,
        "diastolic": 800,
        "insulin": 999999,
        "skinThickness": 500,
        "gender": "female"
    }
    response = client.post('/predict', json=data)
    assert response.status_code in (400, 422)
