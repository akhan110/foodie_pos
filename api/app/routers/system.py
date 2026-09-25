import uuid
from decimal import Decimal
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import (
    Category,
    Product,
    Addon,
    SizeOption,
    Order,
    OrderItem,
    Shift,
    Deal,
    DealItem,
)

router = APIRouter(prefix="/api/v1/system", tags=["System"])


class ResetDataRequest(BaseModel):
    target: str  # "all", "orders", "menu", "seed"


@router.post("/reset-data")
def reset_system_data(req: ResetDataRequest, db: Session = Depends(get_db)):
    """Reset system data: 'orders', 'menu', 'all' (clean slate), or 'seed'."""
    target = req.target.lower().strip()

    try:
        if target in ("orders", "all"):
            # Delete all order items & orders
            db.query(OrderItem).delete()
            db.query(Order).delete()
            # Delete all shifts
            db.query(Shift).delete()
            db.commit()

        if target in ("menu", "all"):
            # Delete deals
            db.query(DealItem).delete()
            db.query(Deal).delete()
            # Delete menu components
            db.query(Addon).delete()
            db.query(SizeOption).delete()
            db.query(Product).delete()
            db.query(Category).delete()

            # Create 1 clean initial default category so the menu is immediately usable
            default_cat = Category(
                id="cat-general",
                name="General",
                sort_order=0,
            )
            db.add(default_cat)
            db.commit()

        if target == "seed":
            # Clear everything first
            db.query(OrderItem).delete()
            db.query(Order).delete()
            db.query(Shift).delete()
            db.query(DealItem).delete()
            db.query(Deal).delete()
            db.query(Addon).delete()
            db.query(SizeOption).delete()
            db.query(Product).delete()
            db.query(Category).delete()
            db.commit()

            # Seed default demo categories
            categories_data = [
                Category(id="cat-burgers", name="Burgers", sort_order=0),
                Category(id="cat-pizzas", name="Pizzas", sort_order=1),
                Category(id="cat-sides", name="Sides", sort_order=2),
                Category(id="cat-drinks", name="Beverages", sort_order=3),
                Category(id="cat-desserts", name="Desserts", sort_order=4),
            ]
            db.add_all(categories_data)
            db.commit()

            # Seed default demo products
            demo_products = [
                Product(
                    id="prod-1",
                    sku="BF-001",
                    name="Classic Smash Burger",
                    category_id="cat-burgers",
                    price=Decimal("620.00"),
                    description="Single smashed beef patty with cheddar cheese and signature sauce.",
                    image="assets/svg/products/burger.svg",
                    is_popular=True,
                    is_combo=False,
                    is_kitchen=True,
                    is_active=True,
                ),
                Product(
                    id="prod-2",
                    sku="BF-002",
                    name="Double Smash Deluxe",
                    category_id="cat-burgers",
                    price=Decimal("890.00"),
                    description="Double beef patty, double cheddar, caramelized onions, and pickles.",
                    image="assets/svg/products/double_burger.svg",
                    is_popular=True,
                    is_combo=False,
                    is_kitchen=True,
                    is_active=True,
                ),
                Product(
                    id="prod-3",
                    sku="BF-003",
                    name="Crispy Chicken Burger",
                    category_id="cat-burgers",
                    price=Decimal("580.00"),
                    description="Golden crispy chicken breast fillet with iceberg lettuce and garlic mayo.",
                    image="assets/svg/products/chicken_burger.svg",
                    is_popular=False,
                    is_combo=False,
                    is_kitchen=True,
                    is_active=True,
                ),
                Product(
                    id="prod-4",
                    sku="BF-004",
                    name="Pepperoni Passion Pizza",
                    category_id="cat-pizzas",
                    price=Decimal("1250.00"),
                    description="Loaded with beef pepperoni slices, mozzarella cheese, and tomato herb base.",
                    image="assets/svg/products/pizza.svg",
                    is_popular=True,
                    is_combo=False,
                    is_kitchen=True,
                    is_active=True,
                ),
                Product(
                    id="prod-5",
                    sku="BF-005",
                    name="Golden French Fries",
                    category_id="cat-sides",
                    price=Decimal("250.00"),
                    description="Skinny salted potato fries cooked to crispy perfection.",
                    image="assets/svg/products/fries.svg",
                    is_popular=False,
                    is_combo=False,
                    is_kitchen=True,
                    is_active=True,
                ),
                Product(
                    id="prod-6",
                    sku="BF-006",
                    name="Chilled Cola 500ml",
                    category_id="cat-drinks",
                    price=Decimal("120.00"),
                    description="Ice cold carbonated cola drink.",
                    image="assets/svg/products/drink.svg",
                    is_popular=False,
                    is_combo=False,
                    is_kitchen=False,
                    is_active=True,
                ),
            ]
            db.add_all(demo_products)
            db.commit()

        return {
            "success": True,
            "message": f"System data reset '{target}' executed successfully.",
            "data": {"target": target},
            "statusCode": 200,
        }

    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to reset system data: {str(e)}",
        )
