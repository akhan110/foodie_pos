from typing import Optional
from uuid import UUID
from pydantic import BaseModel


class PinLoginRequest(BaseModel):
    pin: str


class EmailLoginRequest(BaseModel):
    email: str
    password: str


class SignUpRequest(BaseModel):
    name: str
    store_name: str
    email: str
    phone: Optional[str] = None
    password: str
    pin: Optional[str] = "1234"
    role: Optional[str] = "manager"


class CashierResponse(BaseModel):
    id: UUID
    name: str
    email: Optional[str] = None
    phone: Optional[str] = None
    role: str
    store_name: str
    is_active: bool

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: CashierResponse


class ApiResponse(BaseModel):
    success: bool
    message: str
    data: Optional[dict] = None
    statusCode: int = 200
