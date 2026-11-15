import pytest
from fastapi.testclient import TestClient  

from app import main

client = TestClient(main.app)

@pytest.fixture(autouse=True)
def limpiar_tareas():
    """Antes de CADA prueba, vacía la 'base de datos'."""
    main.tasks.clear()
    main.next_id = 1


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_crear_tarea():
    response = client.post("/tasks", json={"title": "Aprender Docker"})
    assert response.status_code == 201
    data = response.json()
    assert data["id"] == 1
    assert data["title"] == "Aprender Docker"
    assert data["done"] is False


def test_crear_tarea_con_titulo_vacio_falla():
    response = client.post("/tasks", json={"title": ""})
    assert response.status_code == 422


def test_obtener_tarea_inexistente_da_404():
    response = client.get("/tasks/99")
    assert response.status_code == 404

def test_borrar_tarea():
    # 1. Preparar: crear una tarea para tener algo que borrar
    client.post("/tasks", json={"title": "Tarea a borrar"})

    # 2. Actuar: borrarla
    response = client.delete("/tasks/1")

    # 3. Verificar: se borró con éxito y ya no existe
    assert response.status_code == 204
    assert client.get("/tasks/1").status_code == 404


def test_borrar_tarea_inexistente_da_404():
    response = client.delete("/tasks/99")
    assert response.status_code == 404