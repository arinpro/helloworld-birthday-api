from sqlalchemy.orm import Session
from app import models, db
from datetime import date
from sqlalchemy.exc import NoResultFound

def get_user(username: str):
    session: Session = db.SessionLocal()
    try:
        return session.query(models.User).filter(models.User.username == username).first()
    finally:
        session.close()

def create_or_update_user(username: str, dob: date):
    session: Session = db.SessionLocal()
    try:
        user = session.query(models.User).filter(models.User.username == username).first()
        if user:
            user.date_of_birth = dob
        else:
            user = models.User(username=username, date_of_birth=dob)
            session.add(user)
        session.commit()
    finally:
        session.close()
