from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Category, Product
from ..schemas import CategoryResponse, ProductResponse

router = APIRouter(prefix="/api/v1/menu", tags=["Menu & Products"])


@router.get("/categories")
def get_categories(db: Session = Depends(get_db)):
    """Fetch all menu categories in sort order."""
    categories = db.query(Category).order_by(Category.sort_order.asc()).all()
    
    result = []
    for c in categories:
        result.append({
            "id": c.id,
            "name": c.name,
            "slug": c.id,
            "sort_order": c.sort_order,
            "icon": f"assets/svg/products/{c.id}.svg" if c.id in ["burger", "pizza", "chicken", "fries", "drink", "dessert"] else None
        })

    return {
        "success": True,
        "message": "Categories retrieved successfully",
        "data": result,
        "statusCode": 200,
    }


@router.get("/products")
def get_products(
    category_id: Optional[str] = Query(None, description="Filter by category ID/slug (e.g. burgers, pizza)"),
    search: Optional[str] = Query(None, description="Search product name"),
    is_popular: Optional[bool] = Query(None, description="Filter popular items"),
    is_combo: Optional[bool] = Query(None, description="Filter combo meals"),
    db: Session = Depends(get_db),
):
    """Fetch all active products with optional filters."""
    query = db.query(Product).filter(Product.is_active == True)

    if category_id and category_id.strip() and category_id.lower() != "all":
        query = query.filter(Product.category_id == category_id.strip().lower())

    if search and search.strip():
        query = query.filter(Product.name.ilike(f"%{search.strip()}%"))

    if is_popular is not None:
        query = query.filter(Product.is_popular == is_popular)

    if is_combo is not None:
        query = query.filter(Product.is_combo == is_combo)

    products = query.order_by(Product.name.asc()).all()

    result = []
    for p in products:
        result.append({
            "id": p.id,
            "name": p.name,
            "category": p.category_id,
            "category_id": p.category_id,
            "price": float(p.price),
            "image": p.image or "assets/svg/products/burger.svg",
            "is_popular": p.is_popular,
            "is_combo": p.is_combo,
            "is_active": p.is_active,
        })

    return {
        "success": True,
        "message": f"Retrieved {len(result)} products",
        "data": result,
        "statusCode": 200,
    }


@router.get("/products/{product_id}")
def get_product_by_id(product_id: str, db: Session = Depends(get_db)):
    """Fetch single product by its ID."""
    p = db.query(Product).filter(Product.id == product_id, Product.is_active == True).first()
    if not p:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID '{product_id}' not found.",
        )

    product_data = {
        "id": p.id,
        "name": p.name,
        "category": p.category_id,
        "category_id": p.category_id,
        "price": float(p.price),
        "image": p.image or "assets/svg/products/burger.svg",
        "is_popular": p.is_popular,
        "is_combo": p.is_combo,
        "is_active": p.is_active,
    }

    return {
        "success": True,
        "message": "Product retrieved successfully",
        "data": product_data,
        "statusCode": 200,
    }
