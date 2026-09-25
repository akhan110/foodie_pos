from typing import Any, List, Optional
from uuid import UUID
from decimal import Decimal
from pydantic import BaseModel, field_validator


class PinLoginRequest(BaseModel):
    pin: str
    cashier_id: Optional[str] = None


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


class CategoryCreateRequest(BaseModel):
    id: Optional[str] = None
    name: str
    sort_order: Optional[int] = 0


class CategoryUpdateRequest(BaseModel):
    name: Optional[str] = None
    sort_order: Optional[int] = None


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
    sku: Optional[str] = None
    name: str
    category: str
    category_id: str
    price: float
    description: Optional[str] = None
    image: str
    is_popular: bool = False
    is_combo: bool = False
    is_kitchen: bool = True
    is_active: bool = True
    prep_time_minutes: int = 3

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
    sku: Optional[str] = None
    name: str
    category_id: str
    price: float
    description: Optional[str] = None
    image: Optional[str] = "assets/svg/products/burger.svg"
    is_popular: Optional[bool] = False
    is_combo: Optional[bool] = False
    is_kitchen: Optional[bool] = True
    is_active: Optional[bool] = True
    prep_time_minutes: Optional[int] = 3


class ProductUpdateRequest(BaseModel):
    sku: Optional[str] = None
    name: Optional[str] = None
    category_id: Optional[str] = None
    price: Optional[float] = None
    description: Optional[str] = None
    image: Optional[str] = None
    is_popular: Optional[bool] = None
    is_combo: Optional[bool] = None
    is_kitchen: Optional[bool] = None
    is_active: Optional[bool] = None
    prep_time_minutes: Optional[int] = None


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


class SizeOptionCreateRequest(BaseModel):
    id: Optional[str] = None
    name: str
    extra_price: float
    category_id: Optional[str] = None
    is_active: Optional[bool] = True


class SizeOptionUpdateRequest(BaseModel):
    name: Optional[str] = None
    extra_price: Optional[float] = None
    category_id: Optional[str] = None
    is_active: Optional[bool] = None


class OrderItemResponse(BaseModel):
    id: str
    order_id: str
    product_id: Optional[str] = None
    product_name: str
    product_image: Optional[str] = "assets/svg/products/burger.svg"
    size: Optional[str] = "Regular"
    addons: Optional[str] = None
    quantity: int = 1
    unit_price: float
    total_price: float
    prep_time_minutes: int = 3

    @field_validator("unit_price", "total_price", mode="before")
    @classmethod
    def convert_decimal_to_float(cls, v: Any) -> float:
        if isinstance(v, Decimal):
            return float(v)
        return float(v)

    class Config:
        from_attributes = True


class OrderResponse(BaseModel):
    id: str
    order_number: str
    order_type: str
    status: str
    table_number: Optional[str] = None
    cashier_name: str
    payment_method: str
    subtotal: float
    tax: float
    discount: float
    total: float
    amount_received: float
    change_amount: float
    created_at: Any
    items_count: int = 0
    items: List[OrderItemResponse] = []

    @field_validator("subtotal", "tax", "discount", "total", "amount_received", "change_amount", mode="before")
    @classmethod
    def convert_decimal_to_float(cls, v: Any) -> float:
        if isinstance(v, Decimal):
            return float(v)
        return float(v)

    class Config:
        from_attributes = True


class OrderItemCreateRequest(BaseModel):
    id: Optional[str] = None
    product_id: Optional[str] = None
    product_name: str
    product_image: Optional[str] = "assets/svg/products/burger.svg"
    size: Optional[str] = "Regular"
    addons: Optional[str] = None
    quantity: int = 1
    unit_price: float
    total_price: float
    prep_time_minutes: Optional[int] = 3


class OrderCreateRequest(BaseModel):
    id: Optional[str] = None
    order_number: Optional[str] = None
    order_type: Optional[str] = "Dine in"
    status: Optional[str] = "Completed"
    table_number: Optional[str] = "Table 1"
    cashier_name: Optional[str] = "Akhan"
    payment_method: Optional[str] = "Cash"
    subtotal: float
    tax: Optional[float] = 0.0
    discount: Optional[float] = 0.0
    total: float
    amount_received: Optional[float] = None
    change_amount: Optional[float] = 0.0
    items: List[OrderItemCreateRequest] = []


class OrderStatusUpdateRequest(BaseModel):
    status: str


class ApiResponse(BaseModel):
    success: bool
    message: str
    data: Optional[Any] = None
    statusCode: int = 200


class DealItemResponse(BaseModel):
    id: str
    deal_id: Optional[str] = None
    product_id: Optional[str] = None
    product_name: str
    product_image: str = "assets/svg/products/burger.svg"
    quantity: int = 1
    unit_price: float = 0.0
    total_price: float = 0.0

    @field_validator("unit_price", "total_price", mode="before")
    @classmethod
    def convert_decimal_to_float(cls, v: Any) -> float:
        if isinstance(v, Decimal):
            return float(v)
        return float(v or 0.0)

    class Config:
        from_attributes = True


class DealItemCreate(BaseModel):
    id: Optional[str] = None
    product_id: Optional[str] = None
    product_name: str
    product_image: Optional[str] = "assets/svg/products/burger.svg"
    quantity: int = 1
    unit_price: float = 0.0
    total_price: float = 0.0


class DealResponse(BaseModel):
    id: str
    name: str
    description: Optional[str] = None
    category: str = "Meal Combos"
    price: float
    original_price: float = 0.0
    discount_amount: float = 0.0
    image: str = "assets/svg/products/burger.svg"
    is_active: bool = True
    created_at: Optional[Any] = None
    items: List[DealItemResponse] = []

    @field_validator("price", "original_price", "discount_amount", mode="before")
    @classmethod
    def convert_decimal_to_float(cls, v: Any) -> float:
        if isinstance(v, Decimal):
            return float(v)
        return float(v or 0.0)

    class Config:
        from_attributes = True


class DealCreateRequest(BaseModel):
    id: Optional[str] = None
    name: str
    description: Optional[str] = None
    category: Optional[str] = "Meal Combos"
    price: float
    original_price: Optional[float] = 0.0
    discount_amount: Optional[float] = 0.0
    image: Optional[str] = "assets/svg/products/burger.svg"
    is_active: Optional[bool] = True
    items: List[DealItemCreate] = []


class DealUpdateRequest(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    price: Optional[float] = None
    original_price: Optional[float] = None
    discount_amount: Optional[float] = None
    image: Optional[str] = None
    is_active: Optional[bool] = None
    items: Optional[List[DealItemCreate]] = None


