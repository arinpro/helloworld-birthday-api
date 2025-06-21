import os
import pytest
from fastapi.testclient import TestClient
from app.main import app
from app import db
from datetime import date, timedelta

client = TestClient(app)

@pytest.fixture(autouse=True, scope="module")
def setup_test_db():
    db.Base.metadata.create_all(bind=db.engine)
    yield
    db.Base.metadata.drop_all(bind=db.engine)

def test_put_and_get_birthday():
    username = "Alice"
    dob = (date.today() - timedelta(days=10000)).isoformat()
    # PUT valid
    resp = client.put(f"/hello/{username}", json={"dateOfBirth": dob})
    assert resp.status_code == 204
    # GET not birthday
    resp = client.get(f"/hello/{username}")
    assert resp.status_code == 200
    assert "Your birthday is in" in resp.json()["message"]

def test_birthday_today():
    username = "Bob"
    dob = date.today().replace(year=date.today().year - 20).isoformat()
    client.put(f"/hello/{username}", json={"dateOfBirth": dob})
    resp = client.get(f"/hello/{username}")
    assert resp.status_code == 200
    assert "Happy birthday" in resp.json()["message"]

def test_invalid_username():
    resp = client.put("/hello/alice123", json={"dateOfBirth": "2000-01-01"})
    assert resp.status_code == 422

def test_invalid_date():
    username = "Charlie"
    future = (date.today() + timedelta(days=1)).isoformat()
    resp = client.put(f"/hello/{username}", json={"dateOfBirth": future})
    assert resp.status_code == 422
