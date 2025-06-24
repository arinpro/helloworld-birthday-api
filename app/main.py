from fastapi import FastAPI, HTTPException, Path
from fastapi.responses import JSONResponse
from app import crud, schemas, db
from datetime import date
from sqlalchemy.exc import SQLAlchemyError
from prometheus_fastapi_instrumentator import Instrumentator

app = FastAPI()

Instrumentator().instrument(app).expose(app, endpoint="/metrics")


@app.on_event("startup")
def on_startup():
    db.init_db()


@app.get("/")
def root():
    return {"message": "Welcome to the Hello World Birthday API!"}


@app.put("/hello/{username}")
def put_birthday(username: str = Path(..., pattern="^[A-Za-z]+$"), payload: schemas.UserCreate = ...):
    try:
        crud.create_or_update_user(username, payload.dateOfBirth)
        return JSONResponse(status_code=204, content=None)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except SQLAlchemyError:
        raise HTTPException(status_code=500, detail="Database error")


@app.get("/hello/healthz")
def healthz():
    return {"status": "ok"}


@app.get("/hello/{username}")
def get_birthday(username: str = Path(..., pattern="^[A-Za-z]+$")):
    user = crud.get_user(username)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    today = date.today()
    dob = user.date_of_birth
    next_birthday = dob.replace(year=today.year)
    if next_birthday < today:
        next_birthday = next_birthday.replace(year=today.year + 1)
    days = (next_birthday - today).days
    if days == 0:
        msg = f"Hello, {username}! Happy birthday!"
    else:
        msg = f"Hello, {username}! Your birthday is in {days} day(s)"
    return {"message": msg}
