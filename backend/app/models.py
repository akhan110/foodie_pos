import uuid
from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, ForeignKey, Integer, Numeric, String, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship

from .database import Base


class Cashier(Base):
    __tablename__ = "cashiers"

    id = Column(
        UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        server_default=text("gen_random_uuid()"),
    )
    name = Column(String(100), nullable=False)
    email = Column(String(150), unique=True, nullable=True, index=True)
    password_hash = Column(String(255), nullable=True)
    phone = Column(String(50), nullable=True)
    role = Column(String(50), nullable=False, default="manager")
    pin = Column(String(10), nullable=False, default="1234", index=True)
    store_name = Column(String(100), nullable=False, default="BiteFlow Store #01")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)


class Category(Base):
    __tablename__ = "categories"

    id = Column(String(50), primary_key=True)
    name = Column(String(100), nullable=False)
    sort_order = Column(Integer, default=0)

    products = relationship("Product", back_populates="category_rel")


class Product(Base):
    __tablename__ = "products"

    id = Column(String(50), primary_key=True)
    name = Column(String(150), nullable=False)
    category_id = Column(String(50), ForeignKey("categories.id"), nullable=False, index=True)
    price = Column(Numeric(10, 2), nullable=False)
    description = Column(String(500), nullable=True)
    image = Column(String(255), default="assets/svg/products/burger.svg")
    is_popular = Column(Boolean, default=False)
    is_combo = Column(Boolean, default=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    category_rel = relationship("Category", back_populates="products")


class Addon(Base):
    __tablename__ = "addons"

    id = Column(String(50), primary_key=True)
    name = Column(String(100), nullable=False)
    price = Column(Numeric(10, 2), nullable=False, default=0.0)
    category_id = Column(String(50), ForeignKey("categories.id"), nullable=True, index=True)
    is_active = Column(Boolean, default=True)


class SizeOption(Base):
    __tablename__ = "size_options"

    id = Column(String(50), primary_key=True)
    name = Column(String(50), nullable=False)
    extra_price = Column(Numeric(10, 2), nullable=False, default=0.0)
    category_id = Column(String(50), ForeignKey("categories.id"), nullable=True, index=True)
    is_active = Column(Boolean, default=True)


class Order(Base):
    __tablename__ = "orders"

    id = Column(String(50), primary_key=True)
    order_number = Column(String(20), nullable=False, index=True)
    order_type = Column(String(30), nullable=False, default="Dine in")
    status = Column(String(30), nullable=False, default="Completed")
    table_number = Column(String(50), nullable=True, default="Table 1")
    cashier_name = Column(String(100), nullable=False, default="Alex Khan")
    payment_method = Column(String(50), nullable=False, default="Cash")
    subtotal = Column(Numeric(10, 2), nullable=False, default=0.0)
    tax = Column(Numeric(10, 2), nullable=False, default=0.0)
    discount = Column(Numeric(10, 2), nullable=False, default=0.0)
    total = Column(Numeric(10, 2), nullable=False, default=0.0)
    amount_received = Column(Numeric(10, 2), nullable=False, default=0.0)
    change_amount = Column(Numeric(10, 2), nullable=False, default=0.0)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)

    items = relationship("OrderItem", back_populates="order_rel", cascade="all, delete-orphan")


class OrderItem(Base):
    __tablename__ = "order_items"

    id = Column(String(50), primary_key=True)
    order_id = Column(String(50), ForeignKey("orders.id"), nullable=False, index=True)
    product_id = Column(String(50), nullable=True)
    product_name = Column(String(150), nullable=False)
    product_image = Column(String(255), default="assets/svg/products/burger.svg")
    size = Column(String(50), default="Regular")
    addons = Column(String(255), nullable=True)
    quantity = Column(Integer, nullable=False, default=1)
    unit_price = Column(Numeric(10, 2), nullable=False, default=0.0)
    total_price = Column(Numeric(10, 2), nullable=False, default=0.0)
    price = Column(Numeric(10, 2), nullable=True)
    item_total = Column(Numeric(10, 2), nullable=True)

    order_rel = relationship("Order", back_populates="items")


class Shift(Base):
    __tablename__ = "shifts"

    id = Column(String(50), primary_key=True)
    cashier_id = Column(String(50), nullable=True, index=True)
    cashier_name = Column(String(100), nullable=False, default="Alex Khan")
    opening_float = Column(Numeric(10, 2), nullable=False, default=0.0)
    closing_cash = Column(Numeric(10, 2), nullable=True)
    expected_cash = Column(Numeric(10, 2), nullable=True)
    cash_difference = Column(Numeric(10, 2), nullable=True)
    total_sales = Column(Numeric(10, 2), nullable=False, default=0.0)
    cash_sales = Column(Numeric(10, 2), nullable=False, default=0.0)
    card_sales = Column(Numeric(10, 2), nullable=False, default=0.0)
    total_orders = Column(Integer, nullable=False, default=0)
    status = Column(String(30), nullable=False, default="open")  # open, closed
    notes = Column(String(500), nullable=True)
    opened_at = Column(DateTime(timezone=True), default=datetime.utcnow)
    closed_at = Column(DateTime(timezone=True), nullable=True)
