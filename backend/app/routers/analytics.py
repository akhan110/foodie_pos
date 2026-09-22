from datetime import datetime, time
from collections import defaultdict
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func

from ..database import get_db
from ..models import Order, OrderItem

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])


@router.get("/overview")
def get_analytics_overview(db: Session = Depends(get_db)):
    # All completed orders for today
    today_start = datetime.combine(datetime.utcnow().date(), time.min)
    today_end = datetime.combine(datetime.utcnow().date(), time.max)

    today_orders = db.query(Order).filter(
        Order.created_at >= today_start,
        Order.created_at <= today_end,
        Order.status == "Completed",
    ).all()

    total_revenue = sum(float(o.total or 0) for o in today_orders)
    total_orders = len(today_orders)
    avg_order_value = (total_revenue / total_orders) if total_orders > 0 else 0.0
    total_discount = sum(float(o.discount or 0) for o in today_orders)
    total_tax = sum(float(o.tax or 0) for o in today_orders)

    # Payment breakdown
    payment_methods = defaultdict(float)
    for o in today_orders:
        method = o.payment_method or "Cash"
        payment_methods[method] += float(o.total or 0)

    # Top selling items
    order_ids = [o.id for o in today_orders]
    top_items_map = defaultdict(lambda: {"name": "", "quantity": 0, "total": 0.0, "image": ""})

    if order_ids:
        items = db.query(OrderItem).filter(OrderItem.order_id.in_(order_ids)).all()
        for item in items:
            key = item.product_name
            top_items_map[key]["name"] = item.product_name
            top_items_map[key]["quantity"] += item.quantity or 1
            top_items_map[key]["total"] += float(item.total_price or 0)
            if not top_items_map[key]["image"] and item.product_image:
                top_items_map[key]["image"] = item.product_image

    top_items = sorted(top_items_map.values(), key=lambda x: x["quantity"], reverse=True)[:5]

    # Hourly distribution
    hourly_distribution = [0.0] * 24
    for o in today_orders:
        if o.created_at:
            hour = o.created_at.hour
            hourly_distribution[hour] += float(o.total or 0)

    return {
        "success": True,
        "data": {
            "total_revenue": total_revenue,
            "total_orders": total_orders,
            "avg_order_value": round(avg_order_value, 2),
            "total_discount": total_discount,
            "total_tax": total_tax,
            "payment_breakdown": dict(payment_methods),
            "top_selling_items": top_items,
            "hourly_sales": hourly_distribution,
        },
    }
