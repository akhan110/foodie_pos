import os
import shutil
import uuid
from typing import List, Optional
from fastapi import APIRouter, Depends, File, HTTPException, Query, UploadFile, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Addon, Category, Product, SizeOption
from ..schemas import (
    AddonCreateRequest,
    AddonResponse,
    AddonUpdateRequest,
    CategoryCreateRequest,
    CategoryResponse,
    CategoryUpdateRequest,
    ProductCreateRequest,
    ProductResponse,
    ProductUpdateRequest,
    SizeOptionCreateRequest,
    SizeOptionResponse,
)

router = APIRouter(tags=["Menu & Products"])

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
        product_count = db.query(Product).filter(Product.category_id == c.id).count()
        result.append({
            "id": c.id,
            "name": c.name,
            "slug": c.id,
            "sort_order": c.sort_order,
            "product_count": product_count,
            "icon": f"assets/svg/products/{c.id}.svg" if c.id in ["burger", "pizza", "chicken", "fries", "drink", "dessert"] else None
        })

    return {
        "success": True,
        "message": "Categories retrieved successfully",
        "data": result,
        "statusCode": 200,
    }


@router.post("/categories", status_code=status.HTTP_201_CREATED)
def create_category(req: CategoryCreateRequest, db: Session = Depends(get_db)):
    """Create a new menu category."""
    cat_id = req.id if req.id and req.id.strip() else req.name.strip().lower().replace(" ", "_")
    
    existing = db.query(Category).filter(Category.id == cat_id).first()
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Category with ID/slug '{cat_id}' already exists.",
        )

    sort_order = req.sort_order if req.sort_order is not None else db.query(Category).count()
    new_cat = Category(id=cat_id, name=req.name.strip(), sort_order=sort_order)
    db.add(new_cat)
    db.commit()
    db.refresh(new_cat)

    return {
        "success": True,
        "message": f"Category '{new_cat.name}' created successfully",
        "data": {
            "id": new_cat.id,
            "name": new_cat.name,
            "slug": new_cat.id,
            "sort_order": new_cat.sort_order,
            "product_count": 0,
        },
        "statusCode": 201,
    }


@router.put("/categories/{category_id}")
def update_category(category_id: str, req: CategoryUpdateRequest, db: Session = Depends(get_db)):
    """Update a menu category."""
    cat = db.query(Category).filter(Category.id == category_id).first()
    if not cat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Category '{category_id}' not found.",
        )

    if req.name is not None:
        cat.name = req.name.strip()
    if req.sort_order is not None:
        cat.sort_order = req.sort_order

    db.commit()
    db.refresh(cat)

    product_count = db.query(Product).filter(Product.category_id == cat.id).count()

    return {
        "success": True,
        "message": f"Category '{cat.name}' updated successfully",
        "data": {
            "id": cat.id,
            "name": cat.name,
            "slug": cat.id,
            "sort_order": cat.sort_order,
            "product_count": product_count,
        },
        "statusCode": 200,
    }


@router.delete("/categories/{category_id}")
def delete_category(category_id: str, db: Session = Depends(get_db)):
    """Delete a menu category."""
    cat = db.query(Category).filter(Category.id == category_id).first()
    if not cat:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Category '{category_id}' not found.",
        )

    # Delete or reassign products under category
    db.query(Product).filter(Product.category_id == category_id).delete()
    db.delete(cat)
    db.commit()

    return {
        "success": True,
        "message": f"Category '{category_id}' deleted successfully",
        "data": {"id": category_id},
        "statusCode": 200,
    }


@router.get("/products")
def get_products(
    category_id: Optional[str] = Query(None, description="Filter by category ID/slug (e.g. burgers, pizza)"),
    search: Optional[str] = Query(None, description="Search product name"),
    is_popular: Optional[bool] = Query(None, description="Filter popular items"),
    is_combo: Optional[bool] = Query(None, description="Filter combo meals"),
    include_inactive: Optional[bool] = Query(False, description="Include inactive/unavailable products"),
    db: Session = Depends(get_db),
):
    """Fetch products with optional filters."""
    query = db.query(Product)
    if not include_inactive:
        query = query.filter(Product.is_active == True)

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
        sku = p.sku or f"{p.category_id[:3].upper()}-{p.id[-3:].upper()}"
        result.append({
            "id": p.id,
            "sku": sku,
            "name": p.name,
            "category": p.category_id,
            "category_id": p.category_id,
            "price": float(p.price),
            "description": p.description,
            "image": p.image or "assets/svg/products/burger.svg",
            "is_popular": p.is_popular,
            "is_combo": p.is_combo,
            "is_kitchen": p.is_kitchen if p.is_kitchen is not None else True,
            "is_active": p.is_active,
            "prep_time_minutes": getattr(p, "prep_time_minutes", 3) or 3,
        })

    return {
        "success": True,
        "message": f"Retrieved {len(result)} products",
        "data": result,
        "statusCode": 200,
    }


@router.post("/products", status_code=status.HTTP_201_CREATED)
def create_product(req: ProductCreateRequest, db: Session = Depends(get_db)):
    """Create a new menu product."""
    product_id = req.id if req.id and req.id.strip() else f"prod_{uuid.uuid4().hex[:8]}"

    # Verify category exists or fallback
    cat = db.query(Category).filter(Category.id == req.category_id.lower()).first()
    if not cat:
        # Auto-create category if missing
        cat = Category(id=req.category_id.lower(), name=req.category_id.capitalize())
        db.add(cat)
        db.commit()

    sku = req.sku if req.sku and req.sku.strip() else f"{req.category_id[:3].upper()}-{product_id[-3:].upper()}"

    new_product = Product(
        id=product_id,
        sku=sku,
        name=req.name,
        category_id=req.category_id.lower(),
        price=req.price,
        description=req.description,
        image=req.image or "assets/svg/products/burger.svg",
        is_popular=req.is_popular or False,
        is_combo=req.is_combo or False,
        is_kitchen=req.is_kitchen if req.is_kitchen is not None else True,
        is_active=req.is_active if req.is_active is not None else True,
        prep_time_minutes=req.prep_time_minutes or 3,
    )
    db.add(new_product)
    db.commit()
    db.refresh(new_product)

    return {
        "success": True,
        "message": "Product created successfully",
        "data": {
            "id": new_product.id,
            "sku": new_product.sku,
            "name": new_product.name,
            "category": new_product.category_id,
            "category_id": new_product.category_id,
            "price": float(new_product.price),
            "description": new_product.description,
            "image": new_product.image,
            "is_popular": new_product.is_popular,
            "is_combo": new_product.is_combo,
            "is_kitchen": new_product.is_kitchen,
            "is_active": new_product.is_active,
            "prep_time_minutes": new_product.prep_time_minutes or 3,
        },
        "statusCode": 201,
    }


@router.put("/products/{product_id}")
def update_product(product_id: str, req: ProductUpdateRequest, db: Session = Depends(get_db)):
    """Update an existing menu product."""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID '{product_id}' not found.",
        )

    if req.name is not None:
        product.name = req.name
    if req.sku is not None:
        product.sku = req.sku
    if req.category_id is not None:
        product.category_id = req.category_id.lower()
    if req.price is not None:
        product.price = req.price
    if req.description is not None:
        product.description = req.description
    if req.image is not None:
        product.image = req.image
    if req.is_popular is not None:
        product.is_popular = req.is_popular
    if req.is_combo is not None:
        product.is_combo = req.is_combo
    if req.is_kitchen is not None:
        product.is_kitchen = req.is_kitchen
    if req.is_active is not None:
        product.is_active = req.is_active
    if req.prep_time_minutes is not None:
        product.prep_time_minutes = req.prep_time_minutes

    db.commit()
    db.refresh(product)

    return {
        "success": True,
        "message": "Product updated successfully",
        "data": {
            "id": product.id,
            "sku": product.sku or f"{product.category_id[:3].upper()}-{product.id[-3:].upper()}",
            "name": product.name,
            "category": product.category_id,
            "category_id": product.category_id,
            "price": float(product.price),
            "description": product.description,
            "image": product.image,
            "is_popular": product.is_popular,
            "is_combo": product.is_combo,
            "is_kitchen": product.is_kitchen if product.is_kitchen is not None else True,
            "is_active": product.is_active,
            "prep_time_minutes": getattr(product, "prep_time_minutes", 3) or 3,
        },
        "statusCode": 200,
    }


@router.delete("/products/{product_id}")
def delete_product(product_id: str, db: Session = Depends(get_db)):
    """Delete a menu product (or soft deactivate)."""
    product = db.query(Product).filter(Product.id == product_id).first()
    if not product:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Product with ID '{product_id}' not found.",
        )

    db.delete(product)
    db.commit()

    return {
        "success": True,
        "message": f"Product '{product_id}' deleted successfully",
        "data": {"id": product_id},
        "statusCode": 200,
    }


@router.get("/addons")
def get_addons(
    category_id: Optional[str] = Query(None, description="Category filter (e.g. burgers, desserts, pizza, drinks)"),
    db: Session = Depends(get_db),
):
    """Fetch addons / extras for a category or all active addons."""
    db_addons = db.query(Addon).filter(Addon.is_active == True).all()
    
    if not db_addons:
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


@router.post("/addons", status_code=status.HTTP_201_CREATED)
def create_addon(req: AddonCreateRequest, db: Session = Depends(get_db)):
    """Create a new add-on / extra."""
    addon_id = req.id if req.id and req.id.strip() else f"add_{uuid.uuid4().hex[:8]}"

    new_addon = Addon(
        id=addon_id,
        name=req.name,
        price=req.price,
        category_id=req.category_id.lower() if req.category_id else None,
        is_active=req.is_active if req.is_active is not None else True,
    )
    db.add(new_addon)
    db.commit()
    db.refresh(new_addon)

    return {
        "success": True,
        "message": "Addon created successfully",
        "data": {
            "id": new_addon.id,
            "name": new_addon.name,
            "price": float(new_addon.price),
            "category_id": new_addon.category_id,
            "is_active": new_addon.is_active,
        },
        "statusCode": 201,
    }


@router.put("/addons/{addon_id}")
def update_addon(addon_id: str, req: AddonUpdateRequest, db: Session = Depends(get_db)):
    """Update an existing add-on."""
    addon = db.query(Addon).filter(Addon.id == addon_id).first()
    if not addon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Addon with ID '{addon_id}' not found.",
        )

    if req.name is not None:
        addon.name = req.name
    if req.price is not None:
        addon.price = req.price
    if req.category_id is not None:
        addon.category_id = req.category_id.lower()
    if req.is_active is not None:
        addon.is_active = req.is_active

    db.commit()
    db.refresh(addon)

    return {
        "success": True,
        "message": "Addon updated successfully",
        "data": {
            "id": addon.id,
            "name": addon.name,
            "price": float(addon.price),
            "category_id": addon.category_id,
            "is_active": addon.is_active,
        },
        "statusCode": 200,
    }


@router.patch("/addons/{addon_id}/toggle-status")
def toggle_addon_status(addon_id: str, db: Session = Depends(get_db)):
    """Toggle an add-on's active state."""
    addon = db.query(Addon).filter(Addon.id == addon_id).first()
    if not addon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Addon with ID '{addon_id}' not found.",
        )

    addon.is_active = not (addon.is_active or False)
    db.commit()
    db.refresh(addon)

    return {
        "success": True,
        "message": f"Addon '{addon.name}' is now {'active' if addon.is_active else 'inactive'}",
        "data": {
            "id": addon.id,
            "name": addon.name,
            "price": float(addon.price),
            "category_id": addon.category_id,
            "is_active": addon.is_active,
        },
        "statusCode": 200,
    }


@router.delete("/addons/{addon_id}")
def delete_addon(addon_id: str, db: Session = Depends(get_db)):
    """Delete an add-on."""
    addon = db.query(Addon).filter(Addon.id == addon_id).first()
    if not addon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Addon with ID '{addon_id}' not found.",
        )

    db.delete(addon)
    db.commit()

    return {
        "success": True,
        "message": f"Addon '{addon_id}' deleted successfully",
        "data": {"id": addon_id},
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


@router.post("/sizes", status_code=status.HTTP_201_CREATED)
def create_size_option(req: SizeOptionCreateRequest, db: Session = Depends(get_db)):
    """Create a new size option for a category."""
    size_id = req.id if req.id and req.id.strip() else f"sz_{uuid.uuid4().hex[:8]}"

    new_size = SizeOption(
        id=size_id,
        name=req.name,
        extra_price=req.extra_price,
        category_id=req.category_id.lower() if req.category_id else None,
        is_active=req.is_active if req.is_active is not None else True,
    )
    db.add(new_size)
    db.commit()
    db.refresh(new_size)

    return {
        "success": True,
        "message": "Size option created successfully",
        "data": {
            "id": new_size.id,
            "name": new_size.name,
            "extra_price": float(new_size.extra_price),
            "category_id": new_size.category_id,
            "is_active": new_size.is_active,
        },
        "statusCode": 201,
    }


@router.delete("/sizes/{size_id}")
def delete_size_option(size_id: str, db: Session = Depends(get_db)):
    """Delete a size option."""
    size = db.query(SizeOption).filter(SizeOption.id == size_id).first()
    if not size:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Size option with ID '{size_id}' not found.",
        )

    db.delete(size)
    db.commit()

    return {
        "success": True,
        "message": f"Size option '{size_id}' deleted successfully",
        "data": {"id": size_id},
        "statusCode": 200,
    }


@router.get("/products/{product_id}")
def get_product_by_id(product_id: str, db: Session = Depends(get_db)):
    """Fetch single product by its ID."""
    p = db.query(Product).filter(Product.id == product_id).first()
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
        "description": p.description,
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


@router.post("/upload-image")
async def upload_product_image(file: UploadFile = File(...)):
    """Upload a real product photo (.png, .jpg, .jpeg, .webp)."""
    allowed_extensions = {".jpg", ".jpeg", ".png", ".webp", ".svg", ".gif"}
    _, ext = os.path.splitext(file.filename or "")
    ext = ext.lower() if ext else ".jpg"

    if ext not in allowed_extensions:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Unsupported image format '{ext}'. Allowed formats: {', '.join(allowed_extensions)}",
        )

    # Save to uploads directory
    upload_dir = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(__file__))), "uploads")
    os.makedirs(upload_dir, exist_ok=True)

    unique_filename = f"img_{uuid.uuid4().hex[:12]}{ext}"
    file_path = os.path.join(upload_dir, unique_filename)

    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    image_url = f"/uploads/{unique_filename}"

    return {
        "success": True,
        "message": "Image uploaded successfully",
        "data": {
            "image_url": image_url,
            "filename": unique_filename,
        },
        "statusCode": 200,
    }
