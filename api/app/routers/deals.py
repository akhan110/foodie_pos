import uuid
from datetime import datetime
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Deal, DealItem, Product
from ..schemas import ApiResponse, DealCreateRequest, DealResponse, DealUpdateRequest

router = APIRouter(prefix="/api/v1/deals", tags=["deals"])


def _seed_default_deals_if_empty(db: Session):
    count = db.query(Deal).count()
    if count > 0:
        return

    default_deals = [
        {
            "id": "deal-1",
            "name": "Burger Combo",
            "description": "Burger + Fries + Drink",
            "category": "Meal Combos",
            "price": 799.0,
            "original_price": 1060.0,
            "discount_amount": 261.0,
            "image": "assets/svg/products/burger.svg",
            "is_active": True,
            "items": [
                {"id": "ditem-1-1", "product_id": "prod-1", "product_name": "Classic Smash Burger", "product_image": "assets/svg/products/burger.svg", "quantity": 1, "unit_price": 620.0, "total_price": 620.0},
                {"id": "ditem-1-2", "product_id": "prod-4", "product_name": "Sea Salt Fries", "product_image": "assets/svg/products/fries.svg", "quantity": 1, "unit_price": 260.0, "total_price": 260.0},
                {"id": "ditem-1-3", "product_id": "prod-7", "product_name": "Cola", "product_image": "assets/svg/products/drink.svg", "quantity": 1, "unit_price": 180.0, "total_price": 180.0},
            ],
        },
        {
            "id": "deal-2",
            "name": "Pizza Family Deal",
            "description": "2 Large Pizzas + 4 Drinks",
            "category": "Family Deals",
            "price": 2999.0,
            "original_price": 3500.0,
            "discount_amount": 501.0,
            "image": "assets/svg/products/pizza.svg",
            "is_active": True,
            "items": [
                {"id": "ditem-2-1", "product_id": "prod-5", "product_name": "Pepperoni Pizza", "product_image": "assets/svg/products/pizza.svg", "quantity": 2, "unit_price": 890.0, "total_price": 1780.0},
                {"id": "ditem-2-2", "product_id": "prod-7", "product_name": "Cola", "product_image": "assets/svg/products/drink.svg", "quantity": 4, "unit_price": 180.0, "total_price": 720.0},
            ],
        },
        {
            "id": "deal-3",
            "name": "Chicken Meal",
            "description": "Chicken + Fries + Drink",
            "category": "Meal Combos",
            "price": 850.0,
            "original_price": 1180.0,
            "discount_amount": 330.0,
            "image": "assets/svg/products/chicken.svg",
            "is_active": True,
            "items": [
                {"id": "ditem-3-1", "product_id": "prod-6", "product_name": "Crunch Chicken", "product_image": "assets/svg/products/chicken.svg", "quantity": 1, "unit_price": 740.0, "total_price": 740.0},
                {"id": "ditem-3-2", "product_id": "prod-4", "product_name": "Sea Salt Fries", "product_image": "assets/svg/products/fries.svg", "quantity": 1, "unit_price": 260.0, "total_price": 260.0},
                {"id": "ditem-3-3", "product_id": "prod-7", "product_name": "Cola", "product_image": "assets/svg/products/drink.svg", "quantity": 1, "unit_price": 180.0, "total_price": 180.0},
            ],
        },
        {
            "id": "deal-4",
            "name": "Kids Special",
            "description": "Kids Burger + Fries + Juice",
            "category": "Meal Combos",
            "price": 499.0,
            "original_price": 680.0,
            "discount_amount": 181.0,
            "image": "assets/svg/products/burger.svg",
            "is_active": True,
            "items": [
                {"id": "ditem-4-1", "product_id": "prod-1", "product_name": "Kids Burger", "product_image": "assets/svg/products/burger.svg", "quantity": 1, "unit_price": 320.0, "total_price": 320.0},
                {"id": "ditem-4-2", "product_id": "prod-4", "product_name": "Sea Salt Fries", "product_image": "assets/svg/products/fries.svg", "quantity": 1, "unit_price": 260.0, "total_price": 260.0},
            ],
        },
        {
            "id": "deal-5",
            "name": "Snack Box",
            "description": "2 Chicken + 2 Fries + 2 Drinks",
            "category": "Family Deals",
            "price": 1199.0,
            "original_price": 1560.0,
            "discount_amount": 361.0,
            "image": "assets/svg/products/chicken.svg",
            "is_active": False,
            "items": [
                {"id": "ditem-5-1", "product_id": "prod-6", "product_name": "Crunch Chicken", "product_image": "assets/svg/products/chicken.svg", "quantity": 2, "unit_price": 500.0, "total_price": 1000.0},
                {"id": "ditem-5-2", "product_id": "prod-4", "product_name": "Sea Salt Fries", "product_image": "assets/svg/products/fries.svg", "quantity": 2, "unit_price": 260.0, "total_price": 520.0},
            ],
        },
        {
            "id": "deal-6",
            "name": "Couple Deal",
            "description": "1 Large Pizza + 2 Drinks",
            "category": "Limited Time",
            "price": 1299.0,
            "original_price": 1600.0,
            "discount_amount": 301.0,
            "image": "assets/svg/products/pizza.svg",
            "is_active": True,
            "items": [
                {"id": "ditem-6-1", "product_id": "prod-5", "product_name": "Pepperoni Pizza", "product_image": "assets/svg/products/pizza.svg", "quantity": 1, "unit_price": 890.0, "total_price": 890.0},
                {"id": "ditem-6-2", "product_id": "prod-7", "product_name": "Cola", "product_image": "assets/svg/products/drink.svg", "quantity": 2, "unit_price": 180.0, "total_price": 360.0},
            ],
        },
        {
            "id": "deal-7",
            "name": "Dessert Deal",
            "description": "Any Sundae + Drink",
            "category": "Limited Time",
            "price": 399.0,
            "original_price": 550.0,
            "discount_amount": 151.0,
            "image": "assets/svg/products/drink.svg",
            "is_active": True,
            "items": [
                {"id": "ditem-7-1", "product_id": "prod-8", "product_name": "Chocolate Sundae", "product_image": "assets/svg/products/drink.svg", "quantity": 1, "unit_price": 320.0, "total_price": 320.0},
                {"id": "ditem-7-2", "product_id": "prod-7", "product_name": "Cola", "product_image": "assets/svg/products/drink.svg", "quantity": 1, "unit_price": 180.0, "total_price": 180.0},
            ],
        },
        {
            "id": "deal-8",
            "name": "Lunch Special",
            "description": "Burger + Fries + Drink",
            "category": "Limited Time",
            "price": 699.0,
            "original_price": 1060.0,
            "discount_amount": 361.0,
            "image": "assets/svg/products/burger.svg",
            "is_active": False,
            "items": [
                {"id": "ditem-8-1", "product_id": "prod-1", "product_name": "Classic Smash Burger", "product_image": "assets/svg/products/burger.svg", "quantity": 1, "unit_price": 620.0, "total_price": 620.0},
                {"id": "ditem-8-2", "product_id": "prod-4", "product_name": "Sea Salt Fries", "product_image": "assets/svg/products/fries.svg", "quantity": 1, "unit_price": 260.0, "total_price": 260.0},
            ],
        },
    ]

    for d_data in default_deals:
        items_data = d_data.pop("items", [])
        deal = Deal(**d_data)
        db.add(deal)
        db.flush()
        for i_data in items_data:
            item = DealItem(deal_id=deal.id, **i_data)
            db.add(item)

    db.commit()


@router.get("", response_model=ApiResponse)
def get_deals(
    status: Optional[str] = Query(None, description="all, active, inactive"),
    category: Optional[str] = Query(None, description="Meal Combos, Family Deals, Limited Time"),
    search: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    _seed_default_deals_if_empty(db)

    query = db.query(Deal)

    if status and status.lower() == "active":
        query = query.filter(Deal.is_active == True)
    elif status and status.lower() == "inactive":
        query = query.filter(Deal.is_active == False)

    if category and category.lower() not in ["all", "all deals"]:
        query = query.filter(Deal.category.ilike(f"%{category}%"))

    if search:
        s = f"%{search.strip()}%"
        query = query.filter(Deal.name.ilike(s) | Deal.description.ilike(s))

    deals = query.order_by(Deal.created_at.desc()).all()

    deal_list = []
    for d in deals:
        deal_list.append(
            DealResponse(
                id=d.id,
                name=d.name,
                description=d.description,
                category=d.category,
                price=float(d.price or 0),
                original_price=float(d.original_price or 0),
                discount_amount=float(d.discount_amount or 0),
                image=d.image or "assets/svg/products/burger.svg",
                is_active=bool(d.is_active),
                created_at=d.created_at,
                items=[
                    {
                        "id": it.id,
                        "deal_id": it.deal_id,
                        "product_id": it.product_id,
                        "product_name": it.product_name,
                        "product_image": it.product_image or "assets/svg/products/burger.svg",
                        "quantity": it.quantity,
                        "unit_price": float(it.unit_price or 0),
                        "total_price": float(it.total_price or 0),
                    }
                    for it in d.items
                ],
            ).model_dump()
        )

    return ApiResponse(
        success=True,
        message="Deals fetched successfully",
        data=deal_list,
        statusCode=200,
    )


@router.post("", response_model=ApiResponse, status_code=status.HTTP_201_CREATED)
def create_deal(
    req: DealCreateRequest,
    db: Session = Depends(get_db),
):
    deal_id = req.id or f"deal-{uuid.uuid4().hex[:8]}"

    # Compute original price from items if not provided
    calculated_original = sum(it.total_price for it in req.items) if req.items else req.original_price or req.price
    original_price = req.original_price if (req.original_price and req.original_price > 0) else calculated_original
    discount_amount = max(0.0, original_price - req.price)

    # Generate description if empty
    desc = req.description
    if not desc and req.items:
        desc = " + ".join([it.product_name for it in req.items])

    new_deal = Deal(
        id=deal_id,
        name=req.name,
        description=desc,
        category=req.category or "Meal Combos",
        price=req.price,
        original_price=original_price,
        discount_amount=discount_amount,
        image=req.image or "assets/svg/products/burger.svg",
        is_active=True if req.is_active is None else req.is_active,
        created_at=datetime.utcnow(),
    )
    db.add(new_deal)
    db.flush()

    for it in req.items:
        item_id = it.id or f"ditem-{uuid.uuid4().hex[:8]}"
        deal_item = DealItem(
            id=item_id,
            deal_id=deal_id,
            product_id=it.product_id,
            product_name=it.product_name,
            product_image=it.product_image or "assets/svg/products/burger.svg",
            quantity=it.quantity or 1,
            unit_price=it.unit_price or 0.0,
            total_price=it.total_price or ((it.unit_price or 0.0) * (it.quantity or 1)),
        )
        db.add(deal_item)

    db.commit()
    db.refresh(new_deal)

    return ApiResponse(
        success=True,
        message="Deal created successfully",
        data={"id": new_deal.id, "name": new_deal.name},
        statusCode=201,
    )


@router.get("/{deal_id}", response_model=ApiResponse)
def get_deal_by_id(deal_id: str, db: Session = Depends(get_db)):
    deal = db.query(Deal).filter(Deal.id == deal_id).first()
    if not deal:
        raise HTTPException(status_code=404, detail="Deal not found")

    resp = DealResponse(
        id=deal.id,
        name=deal.name,
        description=deal.description,
        category=deal.category,
        price=float(deal.price or 0),
        original_price=float(deal.original_price or 0),
        discount_amount=float(deal.discount_amount or 0),
        image=deal.image or "assets/svg/products/burger.svg",
        is_active=bool(deal.is_active),
        created_at=deal.created_at,
        items=[
            {
                "id": it.id,
                "deal_id": it.deal_id,
                "product_id": it.product_id,
                "product_name": it.product_name,
                "product_image": it.product_image or "assets/svg/products/burger.svg",
                "quantity": it.quantity,
                "unit_price": float(it.unit_price or 0),
                "total_price": float(it.total_price or 0),
            }
            for it in deal.items
        ],
    )
    return ApiResponse(success=True, message="Deal retrieved", data=resp.model_dump(), statusCode=200)


@router.put("/{deal_id}", response_model=ApiResponse)
def update_deal(
    deal_id: str,
    req: DealUpdateRequest,
    db: Session = Depends(get_db),
):
    deal = db.query(Deal).filter(Deal.id == deal_id).first()
    if not deal:
        raise HTTPException(status_code=404, detail="Deal not found")

    if req.name is not None:
        deal.name = req.name
    if req.description is not None:
        deal.description = req.description
    if req.category is not None:
        deal.category = req.category
    if req.price is not None:
        deal.price = req.price
    if req.original_price is not None:
        deal.original_price = req.original_price
    if req.discount_amount is not None:
        deal.discount_amount = req.discount_amount
    if req.image is not None:
        deal.image = req.image
    if req.is_active is not None:
        deal.is_active = req.is_active

    if req.items is not None:
        # Replace items
        db.query(DealItem).filter(DealItem.deal_id == deal_id).delete()
        for it in req.items:
            item_id = it.id or f"ditem-{uuid.uuid4().hex[:8]}"
            deal_item = DealItem(
                id=item_id,
                deal_id=deal_id,
                product_id=it.product_id,
                product_name=it.product_name,
                product_image=it.product_image or "assets/svg/products/burger.svg",
                quantity=it.quantity or 1,
                unit_price=it.unit_price or 0.0,
                total_price=it.total_price or ((it.unit_price or 0.0) * (it.quantity or 1)),
            )
            db.add(deal_item)

    db.commit()
    db.refresh(deal)

    return ApiResponse(
        success=True,
        message="Deal updated successfully",
        data={"id": deal.id, "name": deal.name},
        statusCode=200,
    )


@router.delete("/{deal_id}", response_model=ApiResponse)
def delete_deal(deal_id: str, db: Session = Depends(get_db)):
    deal = db.query(Deal).filter(Deal.id == deal_id).first()
    if not deal:
        raise HTTPException(status_code=404, detail="Deal not found")

    db.delete(deal)
    db.commit()
    return ApiResponse(success=True, message="Deal deleted successfully", statusCode=200)


@router.patch("/{deal_id}/toggle-status", response_model=ApiResponse)
def toggle_deal_status(deal_id: str, db: Session = Depends(get_db)):
    deal = db.query(Deal).filter(Deal.id == deal_id).first()
    if not deal:
        raise HTTPException(status_code=404, detail="Deal not found")

    deal.is_active = not bool(deal.is_active)
    db.commit()
    db.refresh(deal)

    return ApiResponse(
        success=True,
        message=f"Deal {'activated' if deal.is_active else 'deactivated'} successfully",
        data={"id": deal.id, "is_active": deal.is_active},
        statusCode=200,
    )
