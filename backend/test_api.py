from fastapi.testclient import TestClient
from sqlmodel import Session, SQLModel, create_engine
from sqlmodel.pool import StaticPool
import pytest

from main import app
from database import get_session
from models import Module, Experiment

# Setup in-memory SQLite for testing
sqlite_url = "sqlite://"
engine = create_engine(
    sqlite_url,
    connect_args={"check_same_thread": False},
    poolclass=StaticPool,
)

def override_get_session():
    with Session(engine) as session:
        yield session

app.dependency_overrides[get_session] = override_get_session

@pytest.fixture(name="session")
def session_fixture():
    SQLModel.metadata.create_all(engine)
    with Session(engine) as session:
        yield session
    SQLModel.metadata.drop_all(engine)

client = TestClient(app)

def test_read_modules(session: Session):
    # Seed test data
    module = Module(name="Test Physics", description="Description", icon="test")
    session.add(module)
    session.commit()

    response = client.get("/api/modules")
    assert response.status_code == 200
    data = response.json()
    assert len(data) > 0
    assert data[0]["name"] == "Test Physics"

def test_read_experiments(session: Session):
    module = Module(name="Test Physics")
    session.add(module)
    session.commit()
    session.refresh(module)

    exp = Experiment(module_id=module.id, name="Test Exp", initial_params_json="{}")
    session.add(exp)
    session.commit()

    response = client.get(f"/api/experiments/{module.id}")
    assert response.status_code == 200
    data = response.json()
    assert len(data) == 1
    assert data[0]["name"] == "Test Exp"

def test_calculations(session: Session):
    # Test Mirror/Lens Calculation
    module = Module(name="Optics")
    session.add(module)
    session.commit()
    session.refresh(module)
    
    exp = Experiment(module_id=module.id, name="Mirror & Lens Simulation")
    session.add(exp)
    session.commit()
    session.refresh(exp)
    
    # 1/f = 1/do + 1/di => f=10, do=20 => di=20
    response = client.post(f"/api/calculate/{exp.id}", json={"focal_length": 10, "object_distance": 20, "object_height": 5})
    assert response.status_code == 200
    data = response.json()
    assert data["image_distance"] == 20.0
    assert data["magnification"] == -1.0
    
    # Test Photoelectric Effect
    module_m = Module(name="Modern Physics")
    session.add(module_m)
    session.commit()
    session.refresh(module_m)
    
    exp_p = Experiment(module_id=module_m.id, name="Photoelectric Effect")
    session.add(exp_p)
    session.commit()
    session.refresh(exp_p)
    
    # h = 4.135e-15, f=1e15, phi=2.0 => KE = 4.135 - 2.0 = 2.135
    response = client.post(f"/api/calculate/{exp_p.id}", json={"frequency": 1e15, "work_function": 2.0, "intensity": 1.0})
    assert response.status_code == 200
    data = response.json()
    assert round(data["ke_max"], 3) == 2.136 # 4.135667... - 2.0
    assert data["is_emission"] == True
