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
