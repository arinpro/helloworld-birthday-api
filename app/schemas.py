from pydantic import BaseModel, field_validator
from datetime import date


class UserCreate(BaseModel):
    dateOfBirth: date

    @field_validator('dateOfBirth')
    def date_must_be_past(cls, v):
        from datetime import date
        if v >= date.today():
            raise ValueError('dateOfBirth must be before today')
        return v


class UserResponse(BaseModel):
    message: str
