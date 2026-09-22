import uuid
from datetime import datetime
from decimal import Decimal
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException
from pydantic import BaseModel
from sqlalchemy.orm import Session

from ..database import get_db
from ..models import Shift, Order

router = APIRouter(prefix="/api/v1/shifts", tags=["shifts"])


class OpenShiftRequest(BaseModel):
    opening_float: float = 0.0
    cashier_id: Optional[str] = None
    cashier_name: Optional[str] = "Alex Khan"
    notes: Optional[str] = None


class CloseShiftRequest(BaseModel):
    closing_cash: float
    notes: Optional[str] = None


def _calculate_shift_metrics(db: Session, shift: Shift):
    query = db.query(Order).filter(
        Order.created_at >= shift.opened_at,
        Order.status == "Completed",
    )
    if shift.closed_at:
        query = query.filter(Order.created_at <= shift.closed_at)

    orders = query.all()
    total_orders = len(orders)
    total_sales = sum(float(o.total or 0) for o in orders)
    cash_sales = sum(float(o.total or 0) for o in orders if (o.payment_method or "").lower() == "cash")
    card_sales = sum(float(o.total or 0) for o in orders if (o.payment_method or "").lower() != "cash")
    expected_cash = float(shift.opening_float or 0) + cash_sales

    return {
        "total_orders": total_orders,
        "total_sales": total_sales,
        "cash_sales": cash_sales,
        "card_sales": card_sales,
        "expected_cash": expected_cash,
    }


@router.get("/current")
def get_current_shift(db: Session = Depends(get_db)):
    active_shift = db.query(Shift).filter(Shift.status == "open").order_by(Shift.opened_at.desc()).first()
    if not active_shift:
        return {
            "success": True,
            "data": None,
            "message": "No active shift",
        }

    metrics = _calculate_shift_metrics(db, active_shift)
    return {
        "success": True,
        "data": {
            "id": active_shift.id,
            "cashier_id": active_shift.cashier_id,
            "cashier_name": active_shift.cashier_name,
            "opening_float": float(active_shift.opening_float or 0),
            "closing_cash": float(active_shift.closing_cash) if active_shift.closing_cash is not None else None,
            "expected_cash": metrics["expected_cash"],
            "cash_difference": float(active_shift.cash_difference) if active_shift.cash_difference is not None else None,
            "total_sales": metrics["total_sales"],
            "cash_sales": metrics["cash_sales"],
            "card_sales": metrics["card_sales"],
            "total_orders": metrics["total_orders"],
            "status": active_shift.status,
            "notes": active_shift.notes,
            "opened_at": active_shift.opened_at.isoformat() if active_shift.opened_at else None,
            "closed_at": active_shift.closed_at.isoformat() if active_shift.closed_at else None,
        },
    }


@router.post("/open")
def open_shift(payload: OpenShiftRequest, db: Session = Depends(get_db)):
    existing = db.query(Shift).filter(Shift.status == "open").first()
    if existing:
        metrics = _calculate_shift_metrics(db, existing)
        return {
            "success": True,
            "message": "Shift already open",
            "data": {
                "id": existing.id,
                "cashier_name": existing.cashier_name,
                "opening_float": float(existing.opening_float or 0),
                "expected_cash": metrics["expected_cash"],
                "total_sales": metrics["total_sales"],
                "status": existing.status,
                "opened_at": existing.opened_at.isoformat() if existing.opened_at else None,
            },
        }

    new_shift = Shift(
        id=f"shift_{uuid.uuid4().hex[:10]}",
        cashier_id=payload.cashier_id,
        cashier_name=payload.cashier_name or "Alex Khan",
        opening_float=Decimal(str(payload.opening_float)),
        status="open",
        notes=payload.notes,
        opened_at=datetime.utcnow(),
    )
    db.add(new_shift)
    db.commit()
    db.refresh(new_shift)

    return {
        "success": True,
        "message": "Shift opened successfully",
        "data": {
            "id": new_shift.id,
            "cashier_name": new_shift.cashier_name,
            "opening_float": float(new_shift.opening_float or 0),
            "expected_cash": float(new_shift.opening_float or 0),
            "total_sales": 0.0,
            "status": new_shift.status,
            "opened_at": new_shift.opened_at.isoformat(),
        },
    }


@router.post("/close")
def close_shift(payload: CloseShiftRequest, db: Session = Depends(get_db)):
    active_shift = db.query(Shift).filter(Shift.status == "open").order_by(Shift.opened_at.desc()).first()
    if not active_shift:
        raise HTTPException(status_code=400, detail="No active shift found to close")

    metrics = _calculate_shift_metrics(db, active_shift)
    closing_cash = Decimal(str(payload.closing_cash))
    expected_cash = Decimal(str(metrics["expected_cash"]))
    difference = closing_cash - expected_cash

    active_shift.closing_cash = closing_cash
    active_shift.expected_cash = expected_cash
    active_shift.cash_difference = difference
    active_shift.total_sales = Decimal(str(metrics["total_sales"]))
    active_shift.cash_sales = Decimal(str(metrics["cash_sales"]))
    active_shift.card_sales = Decimal(str(metrics["card_sales"]))
    active_shift.total_orders = metrics["total_orders"]
    active_shift.status = "closed"
    active_shift.closed_at = datetime.utcnow()
    if payload.notes:
        active_shift.notes = payload.notes

    db.commit()
    db.refresh(active_shift)

    return {
        "success": True,
        "message": "Shift closed successfully",
        "data": {
            "id": active_shift.id,
            "cashier_name": active_shift.cashier_name,
            "opening_float": float(active_shift.opening_float or 0),
            "closing_cash": float(active_shift.closing_cash or 0),
            "expected_cash": float(active_shift.expected_cash or 0),
            "cash_difference": float(active_shift.cash_difference or 0),
            "total_sales": float(active_shift.total_sales or 0),
            "cash_sales": float(active_shift.cash_sales or 0),
            "card_sales": float(active_shift.card_sales or 0),
            "total_orders": active_shift.total_orders,
            "status": active_shift.status,
            "opened_at": active_shift.opened_at.isoformat(),
            "closed_at": active_shift.closed_at.isoformat(),
        },
    }
