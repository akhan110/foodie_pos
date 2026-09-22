from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Addon, Category, Product, SizeOption
from ..schemas import AddonResponse, CategoryResponse, ProductResponse, SizeOptionResponse

router = APIRouter(prefix="/api/v1/menu", tags=["Menu & Products"])

DEFAULT_ADDONS = [
    # Burgers
    {"id": "b_cheese", "name": "Extra cheese", "price": 90.0, "category_id": "burgers"},
    {"id": "b_jalapenos", "name": "Jalapeños", "price": 60.0, "category_id": "burgers"},
    {"id": "b_patty", "name": "Extra patty", "price": 220.0, "category_id": "burgers"},
    {"id": "b_sauce", "name": "Special sauce", "price": 50.0, "category_id": "burgers"},
    
    # Desserts (e.g. Chocolate Sundae)
    {"id": "d_choc_sauce", "name": "Extra chocolate sauce", "price": 60.0, "category_id": "desserts"},
    {"id": "d_whipped_cream", "name": "Whipped cream", "price": 50.0, "category_id": "desserts"},
    {"id": "d_sprinkles", "name": "Rainbow sprinkles", "price": 30.0, "category_id": "desserts"},
    {"id": "d_icecream_scoop", "name": "Vanilla ice cream scoop", "price": 100.0, "category_id": "desserts"},
    {"id": "d_choco_chips", "name": "Choco chips", "price": 40.0, "category_id": "desserts"},

    # Pizza
    {"id": "p_cheese", "name": "Extra cheese", "price": 120.0, "category_id": "pizza"},
    {"id": "p_mushrooms", "name": "Fresh mushrooms", "price": 80.0, "category_id": "pizza"},
    {"id": "p_olives", "name": "Black olives", "price": 60.0, "category_id": "pizza"},
    {"id": "p_crust", "name": "Stuffed crust", "price": 180.0, "category_id": "pizza"},

    # Chicken
    {"id": "c_garlic_mayo", "name": "Garlic mayo dip", "price": 50.0, "category_id": "chicken"},
    {"id": "c_spicy_peri", "name": "Spicy peri peri sauce", "price": 60.0, "category_id": "chicken"},
    {"id": "c_honey_mustard", "name": "Honey mustard dip", "price": 50.0, "category_id": "chicken"},
    {"id": "c_fries", "name": "Extra crispy fries", "price": 120.0, "category_id": "chicken"},

    # Drinks
    {"id": "dr_ice", "name": "Extra ice", "price": 0.0, "category_id": "drinks"},
    {"id": "dr_lemon", "name": "Lemon slice", "price": 20.0, "category_id": "drinks"},
    {"id": "dr_mint", "name": "Fresh mint leaves", "price": 30.0, "category_id": "drinks"},
    {"id": "dr_syrup", "name": "Flavored vanilla syrup", "price": 50.0, "category_id": "drinks"},

    # Sides
    {"id": "s_cheese_dip", "name": "Melted cheese dip", "price": 90.0, "category_id": "sides"},
    {"id": "s_truffle_mayo", "name": "Truffle mayo", "price": 80.0, "category_id": "sides"},
    {"id": "s_jalapeno_salsa", "name": "Jalapeño salsa", "price": 60.0, "category_id": "sides"},
    {"id": "s_bacon_bits", "name": "Crispy bacon bits", "price": 110.0, "category_id": "sides"},
]

DEFAULT_SIZES = [
    # Standard (Burgers, Chicken, Sides, Combos)
    {"id": "regular", "name": "Regular", "extra_price": 0.0, "category_id": None},
    {"id": "large", "name": "Large", "extra_price": 120.0, "category_id": None},
    {"id": "xl", "name": "XL", "extra_price": 220.0, "category_id": None},

    # Drinks
    {"id": "dr_reg", "name": "Regular", "extra_price": 0.0, "category_id": "drinks"},
    {"id": "dr_lrg", "name": "Large", "extra_price": 60.0, "category_id": "drinks"},
    {"id": "dr_jumbo", "name": "Jumbo", "extra_price": 110.0, "category_id": "drinks"},

    # Pizza
    {"id": "pz_personal", "name": "Regular", "extra_price": 0.0, "category_id": "pizza"},
    {"id": "pz_med", "name": "Medium", "extra_price": 220.0, "category_id": "pizza"},
    {"id": "pz_lrg", "name": "Large", "extra_price": 420.0, "category_id": "pizza"},
]


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


@router.get("/addons")
def get_addons(
    category_id: Optional[str] = Query(None, description="Category filter (e.g. burgers, desserts, pizza, drinks)"),
    db: Session = Depends(get_db),
):
    """Fetch addons / extras for a category or all active addons."""
    # Check if DB has seeded addons
    db_addons = db.query(Addon).filter(Addon.is_active == True).all()
    
    if not db_addons:
        # Seed default addons to DB
        for item in DEFAULT_ADDONS:
            new_addon = Addon(
                id=item["id"],
                name=item["name"],
                price=item["price"],
                category_id=item["category_id"],
                is_active=True,
            )
            db.add(new_addon)
        db.commit()
        db_addons = db.query(Addon).filter(Addon.is_active == True).all()

    items = db_addons
    if category_id and category_id.strip() and category_id.lower() != "all":
        clean_cat = category_id.strip().lower()
        items = [a for a in db_addons if a.category_id == clean_cat or a.category_id is None]
        # If no specific category matched, fallback to matching by prefix or standard
        if not items:
            items = [a for a in db_addons if a.category_id == "burgers"]

    result = [
        {
            "id": a.id,
            "name": a.name,
            "price": float(a.price),
            "category_id": a.category_id,
            "is_active": a.is_active,
        }
        for a in items
    ]

    return {
        "success": True,
        "message": f"Retrieved {len(result)} addons",
        "data": result,
        "statusCode": 200,
    }


@router.get("/sizes")
def get_size_options(
    category_id: Optional[str] = Query(None, description="Category filter"),
    db: Session = Depends(get_db),
):
    """Fetch size options for a category."""
    db_sizes = db.query(SizeOption).filter(SizeOption.is_active == True).all()

    if not db_sizes:
        for item in DEFAULT_SIZES:
            new_size = SizeOption(
                id=item["id"],
                name=item["name"],
                extra_price=item["extra_price"],
                category_id=item["category_id"],
                is_active=True,
            )
            db.add(new_size)
        db.commit()
        db_sizes = db.query(SizeOption).filter(SizeOption.is_active == True).all()

    items = db_sizes
    if category_id and category_id.strip() and category_id.lower() != "all":
        clean_cat = category_id.strip().lower()
        cat_items = [s for s in db_sizes if s.category_id == clean_cat]
        if cat_items:
            items = cat_items
        else:
            items = [s for s in db_sizes if s.category_id is None]

    result = [
        {
            "id": s.id,
            "name": s.name,
            "extra_price": float(s.extra_price),
            "category_id": s.category_id,
            "is_active": s.is_active,
        }
        for s in items
    ]

    return {
        "success": True,
        "message": f"Retrieved {len(result)} size options",
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
