from typing import Any, List, Optional
from uuid import UUID
from decimal import Decimal
from pydantic import BaseModel, field_validator


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


class CategoryResponse(BaseModel):
    id: str
    name: str
    slug: str
    sort_order: int = 0
    icon: Optional[str] = None

    class Config:
        from_attributes = True


class ProductResponse(BaseModel):
    id: str
    name: str
    category: str
    category_id: str
    price: float
    image: str
    is_popular: bool = False
    is_combo: bool = False
    is_active: bool = True

    @field_validator("price", mode="before")
    @classmethod
    def convert_decimal_to_float(cls, v: Any) -> float:
        if isinstance(v, Decimal):
            return float(v)
        return float(v)

    class Config:
        from_attributes = True


class ApiResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None
    statusCode: int = 200
