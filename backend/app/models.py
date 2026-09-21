import uuid
from datetime import datetime
from sqlalchemy import Boolean, Column, DateTime, String, text
from sqlalchemy.dialects.postgresql import UUID

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
    role = Column(String(50), nullable=False, default="cashier")
    pin = Column(String(10), nullable=False, index=True)
    store_name = Column(String(100), nullable=False, default="Store #01")
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime(timezone=True), default=datetime.utcnow)
