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
    pin: str
    email: Optional[str] = None
    password: Optional[str] = None
    role: Optional[str] = "cashier"
    store_name: Optional[str] = "Store #01"



class CashierResponse(BaseModel):
    id: UUID
    name: str
    email: Optional[str] = None
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
