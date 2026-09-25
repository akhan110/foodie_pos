import uuid
from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Order, OrderItem
from ..schemas import (
    OrderCreateRequest,
    OrderItemResponse,
    OrderResponse,
    OrderStatusUpdateRequest,
)

router = APIRouter(tags=["Orders"])


def _seed_default_orders_if_empty(db: Session):
    """Seed initial sample orders matching the POS design if none exist."""
    count = db.query(Order).count()
    if count > 0:
        return

    now = datetime.utcnow()
    sample_data = [
        {
            "id": "ord-1048",
            "order_number": "#1048",
            "order_type": "Dine in",
            "status": "Completed",
            "table_number": "Table 5",
            "cashier_name": "Akhan",
            "payment_method": "Cash",
            "subtotal": 1860.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 1860.0,
            "amount_received": 2000.0,
            "change_amount": 140.0,
            "created_at": now - timedelta(minutes=5),
            "items": [
                {
                    "id": "item-1048-1",
                    "product_id": "prod-1",
                    "product_name": "Classic Smash Burger",
                    "product_image": "assets/svg/products/burger.svg",
                    "size": "Double Patty",
                    "addons": "Extra Cheddar Cheese, Jalapenos",
                    "quantity": 2,
                    "unit_price": 620.0,
                    "total_price": 1240.0,
                },
                {
                    "id": "item-1048-2",
                    "product_id": "prod-4",
                    "product_name": "Sea Salt Fries",
                    "product_image": "assets/svg/products/fries.svg",
                    "size": "Large",
                    "addons": "Spicy Mayo Dip",
                    "quantity": 1,
                    "unit_price": 260.0,
                    "total_price": 260.0,
                },
                {
                    "id": "item-1048-3",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 180.0,
                    "total_price": 360.0,
                },
            ],
        },
        {
            "id": "ord-1047",
            "order_number": "#1047",
            "order_type": "Takeaway",
            "status": "Completed",
            "table_number": "Counter",
            "cashier_name": "Akhan",
            "payment_method": "Card",
            "subtotal": 1050.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 1050.0,
            "amount_received": 1050.0,
            "change_amount": 0.0,
            "created_at": now - timedelta(minutes=15),
            "items": [
                {
                    "id": "item-1047-1",
                    "product_id": "prod-2",
                    "product_name": "Double Cheese Beast",
                    "product_image": "assets/svg/products/double_burger.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 850.0,
                    "total_price": 850.0,
                },
                {
                    "id": "item-1047-2",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 200.0,
                    "total_price": 200.0,
                },
            ],
        },
        {
            "id": "ord-1046",
            "order_number": "#1046",
            "order_type": "Delivery",
            "status": "Preparing",
            "table_number": "Online Rider",
            "cashier_name": "Akhan",
            "payment_method": "Online",
            "subtotal": 1240.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 1240.0,
            "amount_received": 1240.0,
            "change_amount": 0.0,
            "created_at": now - timedelta(minutes=40),
            "items": [
                {
                    "id": "item-1046-1",
                    "product_id": "prod-3",
                    "product_name": "Crispy Zinger Crunch",
                    "product_image": "assets/svg/products/zinger.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 520.0,
                    "total_price": 1040.0,
                },
                {
                    "id": "item-1046-2",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 200.0,
                    "total_price": 200.0,
                },
            ],
        },
        {
            "id": "ord-1045",
            "order_number": "#1045",
            "order_type": "Dine in",
            "status": "Voided",
            "table_number": "Table 2",
            "cashier_name": "Akhan",
            "payment_method": "Cash",
            "subtotal": 1430.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 1430.0,
            "amount_received": 0.0,
            "change_amount": 0.0,
            "created_at": now - timedelta(hours=1, minutes=10),
            "items": [
                {
                    "id": "item-1045-1",
                    "product_id": "prod-1",
                    "product_name": "Classic Smash Burger",
                    "product_image": "assets/svg/products/burger.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 620.0,
                    "total_price": 1240.0,
                },
                {
                    "id": "item-1045-2",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 190.0,
                    "total_price": 190.0,
                },
            ],
        },
        {
            "id": "ord-1044",
            "order_number": "#1044",
            "order_type": "Takeaway",
            "status": "Completed",
            "table_number": "Counter",
            "cashier_name": "Akhan",
            "payment_method": "Cash",
            "subtotal": 1620.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 1620.0,
            "amount_received": 2000.0,
            "change_amount": 380.0,
            "created_at": now - timedelta(hours=2, minutes=20),
            "items": [
                {
                    "id": "item-1044-1",
                    "product_id": "prod-2",
                    "product_name": "Double Cheese Beast",
                    "product_image": "assets/svg/products/double_burger.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 850.0,
                    "total_price": 850.0,
                },
                {
                    "id": "item-1044-2",
                    "product_id": "prod-5",
                    "product_name": "Loaded Peri Fries",
                    "product_image": "assets/svg/products/peri_fries.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 420.0,
                    "total_price": 420.0,
                },
                {
                    "id": "item-1044-3",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 175.0,
                    "total_price": 350.0,
                },
            ],
        },
        {
            "id": "ord-1043",
            "order_number": "#1043",
            "order_type": "Delivery",
            "status": "Completed",
            "table_number": "Online Rider",
            "cashier_name": "Akhan",
            "payment_method": "Card",
            "subtotal": 1810.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 1810.0,
            "amount_received": 1810.0,
            "change_amount": 0.0,
            "created_at": now - timedelta(hours=3, minutes=15),
            "items": [
                {
                    "id": "item-1043-1",
                    "product_id": "prod-6",
                    "product_name": "Pepperoni Feast Pizza",
                    "product_image": "assets/svg/products/pizza.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 1450.0,
                    "total_price": 1450.0,
                },
                {
                    "id": "item-1043-2",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 180.0,
                    "total_price": 360.0,
                },
            ],
        },
        {
            "id": "ord-1042",
            "order_number": "#1042",
            "order_type": "Dine in",
            "status": "Preparing",
            "table_number": "Table 8",
            "cashier_name": "Akhan",
            "payment_method": "Cash",
            "subtotal": 2000.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 2000.0,
            "amount_received": 2000.0,
            "change_amount": 0.0,
            "created_at": now - timedelta(hours=4, minutes=5),
            "items": [
                {
                    "id": "item-1042-1",
                    "product_id": "prod-1",
                    "product_name": "Classic Smash Burger",
                    "product_image": "assets/svg/products/burger.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 620.0,
                    "total_price": 1240.0,
                },
                {
                    "id": "item-1042-2",
                    "product_id": "prod-5",
                    "product_name": "Loaded Peri Fries",
                    "product_image": "assets/svg/products/peri_fries.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 420.0,
                    "total_price": 420.0,
                },
                {
                    "id": "item-1042-3",
                    "product_id": "prod-8",
                    "product_name": "Iced Lemon Tea",
                    "product_image": "assets/svg/products/ice_tea.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 170.0,
                    "total_price": 340.0,
                },
            ],
        },
        {
            "id": "ord-1041",
            "order_number": "#1041",
            "order_type": "Takeaway",
            "status": "Voided",
            "table_number": "Counter",
            "cashier_name": "Akhan",
            "payment_method": "Cash",
            "subtotal": 2190.0,
            "tax": 0.0,
            "discount": 0.0,
            "total": 2190.0,
            "amount_received": 0.0,
            "change_amount": 0.0,
            "created_at": now - timedelta(hours=5),
            "items": [
                {
                    "id": "item-1041-1",
                    "product_id": "prod-2",
                    "product_name": "Double Cheese Beast",
                    "product_image": "assets/svg/products/double_burger.svg",
                    "size": "Regular",
                    "quantity": 2,
                    "unit_price": 850.0,
                    "total_price": 1700.0,
                },
                {
                    "id": "item-1041-2",
                    "product_id": "prod-4",
                    "product_name": "Sea Salt Fries",
                    "product_image": "assets/svg/products/fries.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 260.0,
                    "total_price": 260.0,
                },
                {
                    "id": "item-1041-3",
                    "product_id": "prod-7",
                    "product_name": "Cola",
                    "product_image": "assets/svg/products/cola.svg",
                    "size": "Regular",
                    "quantity": 1,
                    "unit_price": 230.0,
                    "total_price": 230.0,
                },
            ],
        },
    ]

    for ord_info in sample_data:
        items_data = ord_info.pop("items")
        new_order = Order(**ord_info)
        db.add(new_order)
        for it in items_data:
            new_item = OrderItem(order_id=new_order.id, **it)
            db.add(new_item)

    db.commit()


@router.get("")
def get_orders(
    status_filter: Optional[str] = Query(None, alias="status"),
    order_type: Optional[str] = Query(None, alias="type"),
    search: Optional[str] = Query(None),
    db: Session = Depends(get_db),
):
    """Retrieve all restaurant orders with optional filtering."""
    _seed_default_orders_if_empty(db)

    query = db.query(Order)

    if status_filter and status_filter.lower() != "all" and status_filter.lower() != "all statuses":
        query = query.filter(Order.status.ilike(status_filter.strip()))

    if order_type and order_type.lower() != "all" and order_type.lower() != "all types":
        query = query.filter(Order.order_type.ilike(order_type.strip()))

    if search and search.strip():
        term = f"%{search.strip()}%"
        query = query.filter(
            (Order.order_number.ilike(term))
            | (Order.table_number.ilike(term))
            | (Order.cashier_name.ilike(term))
        )

    orders = query.order_by(Order.created_at.desc()).all()

    result = []
    for o in orders:
        items_count = sum(item.quantity for item in o.items)
        items_list = [
            OrderItemResponse.model_validate(item).model_dump(mode="json")
            for item in o.items
        ]
        ord_dict = OrderResponse.model_validate(o).model_dump(mode="json")
        ord_dict["items_count"] = items_count
        ord_dict["items"] = items_list
        result.append(ord_dict)

    return {
        "success": True,
        "message": f"Retrieved {len(result)} orders successfully.",
        "data": result,
        "statusCode": 200,
    }


@router.get("/{order_id}")
def get_order_details(order_id: str, db: Session = Depends(get_db)):
    """Get single order with full item breakdown."""
    _seed_default_orders_if_empty(db)

    order = (
        db.query(Order)
        .filter((Order.id == order_id) | (Order.order_number == order_id))
        .first()
    )
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{order_id}' not found.",
        )

    items_list = [
        OrderItemResponse.model_validate(item).model_dump(mode="json")
        for item in order.items
    ]
    ord_dict = OrderResponse.model_validate(order).model_dump(mode="json")
    ord_dict["items_count"] = sum(item.quantity for item in order.items)
    ord_dict["items"] = items_list

    return {
        "success": True,
        "message": "Order retrieved successfully.",
        "data": ord_dict,
        "statusCode": 200,
    }


@router.post("")
def create_order(payload: OrderCreateRequest, db: Session = Depends(get_db)):
    """Create and record a new POS order."""
    order_id = payload.id or f"ord-{uuid.uuid4().hex[:8]}"

    if not payload.order_number:
        # Generate next sequential order number
        count = db.query(Order).count()
        order_number = f"#{1049 + count}"
    else:
        order_number = payload.order_number

    new_order = Order(
        id=order_id,
        order_number=order_number,
        order_type=payload.order_type or "Dine in",
        status=payload.status or "Completed",
        table_number=payload.table_number or "Table 1",
        cashier_name=payload.cashier_name or "Akhan",
        payment_method=payload.payment_method or "Cash",
        subtotal=payload.subtotal,
        tax=payload.tax or 0.0,
        discount=payload.discount or 0.0,
        total=payload.total,
        amount_received=payload.amount_received if payload.amount_received is not None else payload.total,
        change_amount=payload.change_amount or 0.0,
        created_at=datetime.utcnow(),
    )

    db.add(new_order)

    for it in payload.items:
        item_id = it.id or f"item-{uuid.uuid4().hex[:8]}"
        order_item = OrderItem(
            id=item_id,
            order_id=order_id,
            product_id=it.product_id,
            product_name=it.product_name,
            product_image=it.product_image or "assets/svg/products/burger.svg",
            size=it.size or "Regular",
            addons=it.addons,
            quantity=it.quantity,
            unit_price=it.unit_price,
            total_price=it.total_price,
            price=it.unit_price,
            item_total=it.total_price,
        )
        db.add(order_item)

    db.commit()
    db.refresh(new_order)

    items_list = [
        OrderItemResponse.model_validate(item).model_dump(mode="json")
        for item in new_order.items
    ]
    ord_dict = OrderResponse.model_validate(new_order).model_dump(mode="json")
    ord_dict["items_count"] = sum(item.quantity for item in new_order.items)
    ord_dict["items"] = items_list

    return {
        "success": True,
        "message": f"Order {new_order.order_number} created successfully.",
        "data": ord_dict,
        "statusCode": 201,
    }


@router.patch("/{order_id}/status")
def update_order_status(
    order_id: str,
    payload: OrderStatusUpdateRequest,
    db: Session = Depends(get_db),
):
    """Update order status (e.g. Completed, Preparing, Voided)."""
    order = (
        db.query(Order)
        .filter((Order.id == order_id) | (Order.order_number == order_id))
        .first()
    )
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{order_id}' not found.",
        )

    order.status = payload.status
    db.commit()
    db.refresh(order)

    items_list = [
        OrderItemResponse.model_validate(item).model_dump(mode="json")
        for item in order.items
    ]
    ord_dict = OrderResponse.model_validate(order).model_dump(mode="json")
    ord_dict["items_count"] = sum(item.quantity for item in order.items)
    ord_dict["items"] = items_list

    return {
        "success": True,
        "message": f"Order {order.order_number} status updated to {order.status}.",
        "data": ord_dict,
        "statusCode": 200,
    }


@router.delete("/{order_id}")
def delete_order(order_id: str, db: Session = Depends(get_db)):
    """Delete an order by ID or order_number."""
    order = (
        db.query(Order)
        .filter((Order.id == order_id) | (Order.order_number == order_id))
        .first()
    )
    if not order:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Order '{order_id}' not found.",
        )

    order_num = order.order_number
    db.delete(order)
    db.commit()

    return {
        "success": True,
        "message": f"Order {order_num} deleted successfully.",
        "data": None,
        "statusCode": 200,
    }
