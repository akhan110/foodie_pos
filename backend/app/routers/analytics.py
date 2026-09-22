from datetime import datetime, time, timedelta
from collections import defaultdict
from typing import Optional
from fastapi import APIRouter, Depends, Query
from sqlalchemy.orm import Session
from sqlalchemy import func

from ..database import get_db
from ..models import Order, OrderItem

router = APIRouter(prefix="/api/v1/analytics", tags=["analytics"])


@router.get("/overview")
def get_analytics_overview(
    range: str = Query("Today", description="Today, This Week, This Month"),
    db: Session = Depends(get_db),
):
    now = datetime.utcnow()

    # Time range boundary calculation
    if range == "This Week":
        start_date = now - timedelta(days=7)
        prev_start = now - timedelta(days=14)
        prev_end = start_date
        comparison_label = "vs. last week"
    elif range == "This Month":
        start_date = now - timedelta(days=30)
        prev_start = now - timedelta(days=60)
        prev_end = start_date
        comparison_label = "vs. last month"
    else:  # Default "Today"
        start_date = datetime.combine(now.date(), time.min)
        prev_start = datetime.combine((now - timedelta(days=1)).date(), time.min)
        prev_end = datetime.combine((now - timedelta(days=1)).date(), time.max)
        comparison_label = "vs. yesterday"

    # Current period completed orders
    current_orders = (
        db.query(Order)
        .filter(Order.created_at >= start_date, Order.status == "Completed")
        .order_by(Order.created_at.desc())
        .all()
    )

    # Previous period completed orders for percentage change
    prev_orders = (
        db.query(Order)
        .filter(
            Order.created_at >= prev_start,
            Order.created_at <= prev_end,
            Order.status == "Completed",
        )
        .all()
    )

    total_revenue = sum(float(o.total or 0) for o in current_orders)
    completed_orders = len(current_orders)
    avg_order_value = (total_revenue / completed_orders) if completed_orders > 0 else 0.0
    total_tax = sum(float(o.tax or 0) for o in current_orders)
    total_discount = sum(float(o.discount or 0) for o in current_orders)
    taxes_and_discounts = total_tax + total_discount

    # Percentage changes
    prev_rev = sum(float(o.total or 0) for o in prev_orders)
    prev_ord = len(prev_orders)
    prev_aov = (prev_rev / prev_ord) if prev_ord > 0 else 0.0
    prev_tax = sum(float((o.tax or 0) + (o.discount or 0)) for o in prev_orders)

    def calc_change(current_val: float, prev_val: float) -> str:
        if prev_val <= 0:
            return "+100%" if current_val > 0 else "0.0%"
        diff = ((current_val - prev_val) / prev_val) * 100
        sign = "+" if diff >= 0 else ""
        return f"{sign}{diff:.1f}%"

    revenue_change = calc_change(total_revenue, prev_rev)
    orders_change = calc_change(completed_orders, prev_ord)
    aov_change = calc_change(avg_order_value, prev_aov)
    tax_change = calc_change(taxes_and_discounts, prev_tax)

    # 1. Hourly distribution (8 AM to 11 PM)
    hours_labels = ["8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM", "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM"]
    hourly_rev_map = defaultdict(float)
    hourly_ord_map = defaultdict(int)

    for o in current_orders:
        if o.created_at:
            h = o.created_at.hour
            # Map hour (8..23) to label
            if 8 <= h <= 23:
                lbl = f"{h if h <= 12 else h - 12}{'AM' if h < 12 else 'PM'}"
                hourly_rev_map[lbl] += float(o.total or 0)
                hourly_ord_map[lbl] += 1

    hourly_data = [
        {
            "label": lbl,
            "revenue": round(hourly_rev_map.get(lbl, 0.0), 2),
            "orders": hourly_ord_map.get(lbl, 0),
        }
        for lbl in hours_labels
    ]

    # 2. Order Types breakdown
    order_type_counts = defaultdict(int)
    for o in current_orders:
        otype = o.order_type or "Dine in"
        # Standardize naming
        if "dine" in otype.lower():
            standard_type = "Dine In"
        elif "take" in otype.lower():
            standard_type = "Takeaway"
        elif "deliver" in otype.lower():
            standard_type = "Delivery"
        elif "drive" in otype.lower():
            standard_type = "Drive Through"
        else:
            standard_type = otype.capitalize()
        order_type_counts[standard_type] += 1

    expected_types = ["Dine In", "Takeaway", "Delivery", "Drive Through"]
    order_types_list = []
    for etype in expected_types:
        count = order_type_counts.get(etype, 0)
        pct = int(round((count / completed_orders * 100))) if completed_orders > 0 else 0
        order_types_list.append({
            "type": etype,
            "count": count,
            "percentage": pct,
        })

    # 3. Top selling items (aggregated from OrderItems)
    current_order_ids = [o.id for o in current_orders]
    top_items_map = defaultdict(lambda: {"name": "", "quantity": 0, "price": 0.0, "image": ""})

    if current_order_ids:
        items = db.query(OrderItem).filter(OrderItem.order_id.in_(current_order_ids)).all()
        for it in items:
            k = it.product_name
            top_items_map[k]["name"] = it.product_name
            top_items_map[k]["quantity"] += it.quantity or 1
            top_items_map[k]["price"] = float(it.unit_price or it.total_price or 0)
            if not top_items_map[k]["image"] and it.product_image:
                top_items_map[k]["image"] = it.product_image

    top_selling_items = sorted(top_items_map.values(), key=lambda x: x["quantity"], reverse=True)[:5]

    # 4. Recent orders (latest 5 orders of any status)
    latest_orders = db.query(Order).order_by(Order.created_at.desc()).limit(5).all()
    recent_orders = []
    for lo in latest_orders:
        t_str = lo.created_at.strftime("%I:%M %p") if lo.created_at else "12:00 PM"
        item_count = len(lo.items) if lo.items else 1
        recent_orders.append({
            "order_number": lo.order_number,
            "time": t_str,
            "order_type": lo.order_type or "Dine In",
            "items_count": item_count,
            "total": float(lo.total or 0),
            "status": lo.status or "Completed",
        })

    # 5. Payment Methods breakdown
    payment_map = defaultdict(float)
    for o in current_orders:
        pm = o.payment_method or "Cash"
        # Standardize
        if "cash" in pm.lower():
            pm_key = "Cash"
        elif "card" in pm.lower():
            pm_key = "Card"
        elif "mobile" in pm.lower() or "qr" in pm.lower():
            pm_key = "Mobile Payment"
        else:
            pm_key = "Other"
        payment_map[pm_key] += float(o.total or 0)

    payment_methods_resp = {}
    for method, icon in [("Cash", "💵"), ("Card", "💳"), ("Mobile Payment", "📱"), ("Other", "⋯")]:
        amt = payment_map.get(method, 0.0)
        pct = int(round((amt / total_revenue * 100))) if total_revenue > 0 else 0
        payment_methods_resp[method] = {
            "pct": pct,
            "amount": round(amt, 2),
            "icon": icon,
        }

    return {
        "success": True,
        "data": {
            "total_revenue": round(total_revenue, 2),
            "revenue_change": revenue_change,
            "completed_orders": completed_orders,
            "orders_change": orders_change,
            "avg_order_value": round(avg_order_value, 2),
            "aov_change": aov_change,
            "taxes_and_discounts": round(taxes_and_discounts, 2),
            "tax_change": tax_change,
            "comparison_label": comparison_label,
            "hourly_data": hourly_data,
            "order_types": order_types_list,
            "top_selling_items": top_selling_items,
            "recent_orders": recent_orders,
            "payment_methods": payment_methods_resp,
        },
    }
