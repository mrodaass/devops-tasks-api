import os
from datetime import datetime, timezone

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, Field
#Variables de entorno: la misma app se comporta distinto segun donde corre.

APP_VERSION = os.getenv("APP_VERSION", "0.1.0")
ENVIRONMENT = os.getenv("ENVIRONMENT", "local")

app = FastAPI(title= "DevOps Task API", version= APP_VERSION)

#Modelos
class TaskCreate(BaseModel):
    """Lo que el cliente envia para crear una tarea."""
    title: str = Field(min_length=1, max_length=200)

class Task(BaseModel):
    """Lo que la API devuelve."""
    id:int
    title:str
    done: bool = False
    created_at: datetime

#Base de datos en memoria

tasks: dict[int,Task] = {}
next_id = 1



#endpoints
@app.get("/health")
def health():
    return {"status": "ok", "version": APP_VERSION, "environment": ENVIRONMENT}


@app.get("/tasks", response_model=list[Task])                # NUEVO
def list_tasks():
    return list(tasks.values())


@app.post("/tasks", response_model=Task, status_code=status.HTTP_201_CREATED)   # NUEVO
def create_task(payload: TaskCreate):
    global next_id
    task = Task(id=next_id, title=payload.title, created_at=datetime.now(timezone.utc))
    tasks[task.id] = task
    next_id += 1
    return task


@app.get("/tasks/{task_id}", response_model=Task)            # NUEVO
def get_task(task_id: int):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    return tasks[task_id]

@app.delete("/tasks/{task_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_task(task_id: int):
    if task_id not in tasks:
        raise HTTPException(status_code=404, detail="Tarea no encontrada")
    del tasks[task_id]