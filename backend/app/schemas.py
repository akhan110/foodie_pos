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
    pin: str
    email: Optional[str] = None
    phone: Optional[str] = None
    password: Optional[str] = None
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
    description: Optional[str] = None
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


class ProductCreateRequest(BaseModel):
    id: Optional[str] = None
    name: str
    category_id: str
    price: float
    description: Optional[str] = None
    image: Optional[str] = "assets/svg/products/burger.svg"
    is_popular: Optional[bool] = False
    is_combo: Optional[bool] = False
    is_active: Optional[bool] = True


class ProductUpdateRequest(BaseModel):
    name: Optional[str] = None
    category_id: Optional[str] = None
    price: Optional[float] = None
    description: Optional[str] = None
    image: Optional[str] = None
    is_popular: Optional[bool] = None
    is_combo: Optional[bool] = None
    is_active: Optional[bool] = None


class AddonResponse(BaseModel):
    id: str
    name: str
    price: float
    category_id: Optional[str] = None
    is_active: bool = True

    @field_validator("price", mode="before")
    @classmethod
    def convert_decimal_to_float(cls, v: Any) -> float:
        if isinstance(v, Decimal):
            return float(v)
        return float(v)

    class Config:
        from_attributes = True


class AddonCreateRequest(BaseModel):
    id: Optional[str] = None
    name: str
    price: float
    category_id: Optional[str] = None
    is_active: Optional[bool] = True


class AddonUpdateRequest(BaseModel):
    name: Optional[str] = None
    price: Optional[float] = None
    category_id: Optional[str] = None
    is_active: Optional[bool] = None


class SizeOptionResponse(BaseModel):
    id: str
    name: str
    extra_price: float
    category_id: Optional[str] = None
    is_active: bool = True

    @field_validator("extra_price", mode="before")
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
