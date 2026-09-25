from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from ..auth import (
    create_access_token,
    get_current_user,
    get_password_hash,
    verify_password,
)
from ..database import get_db
from ..models import Cashier
from ..schemas import (
    CashierResponse,
    EmailLoginRequest,
    PinLoginRequest,
    SignUpRequest,
    TokenResponse,
)

router = APIRouter(tags=["Authentication"])


@router.get("/cashiers")
def get_active_cashiers(db: Session = Depends(get_db)):
    """Fetch list of all active cashiers/staff for quick PIN login selector."""
    cashiers = (
        db.query(Cashier)
        .filter(Cashier.is_active == True)
        .order_by(Cashier.name.asc())
        .all()
    )
    result = [
        CashierResponse.model_validate(c).model_dump(mode="json")
        for c in cashiers
    ]
    return {
        "success": True,
        "message": f"Retrieved {len(result)} cashiers.",
        "data": result,
        "statusCode": 200,
    }


@router.post("/pin-login")
def pin_login(payload: PinLoginRequest, db: Session = Depends(get_db)):
    """Fast-food counter quick 4-digit PIN login."""
    pin = payload.pin.strip()

    query = db.query(Cashier).filter(Cashier.is_active == True)

    if payload.cashier_id and payload.cashier_id.strip():
        # Match by specific selected cashier ID
        cashier_id_clean = payload.cashier_id.strip()
        cashier = query.filter(
            (Cashier.id == cashier_id_clean) | (Cashier.name.ilike(cashier_id_clean))
        ).first()

        if not cashier:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Selected cashier account not found.",
            )

        if (cashier.pin or "").strip() != pin:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail=f"Incorrect PIN for {cashier.name}. Please try again.",
            )
    else:
        # Fallback to finding by PIN
        cashier = query.filter(Cashier.pin == pin).first()
        if not cashier:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid 4-digit PIN. Please try again.",
            )

    access_token = create_access_token(
        data={"sub": str(cashier.id), "name": cashier.name, "role": cashier.role}
    )

    user_data = CashierResponse.model_validate(cashier).model_dump(mode="json")

    return {
        "success": True,
        "message": f"Welcome back, {cashier.name}!",
        "data": {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user_data,
        },
        "statusCode": 200,
    }


@router.post("/signup")
def signup(payload: SignUpRequest, db: Session = Depends(get_db)):
    """Create a new cashier or manager account."""
    email_clean = (
        payload.email.strip().lower()
        if payload.email and payload.email.strip()
        else None
    )
    if email_clean:
        existing = db.query(Cashier).filter(Cashier.email == email_clean).first()
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="An account with this email already exists.",
            )

    pin_clean = (payload.pin or "1234").strip()
    if not pin_clean:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A 4-digit PIN is required.",
        )

    password_hash = (
        get_password_hash(payload.password) if payload.password else None
    )

    new_cashier = Cashier(
        name=payload.name.strip(),
        email=email_clean,
        password_hash=password_hash,
        phone=payload.phone.strip() if payload.phone else None,
        pin=pin_clean,
        role=payload.role or "manager",
        store_name=payload.store_name.strip() or "BiteFlow Store #01",
        is_active=True,
    )

    db.add(new_cashier)
    db.commit()
    db.refresh(new_cashier)

    access_token = create_access_token(
        data={
            "sub": str(new_cashier.id),
            "name": new_cashier.name,
            "role": new_cashier.role,
        }
    )

    user_data = CashierResponse.model_validate(new_cashier).model_dump(mode="json")

    return {
        "success": True,
        "message": f"Welcome to BiteFlow POS, {new_cashier.name}!",
        "data": {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user_data,
        },
        "statusCode": 201,
    }


@router.post("/login")
def email_login(payload: EmailLoginRequest, db: Session = Depends(get_db)):
    """Email and password login for managers and store owners."""
    user = (
        db.query(Cashier)
        .filter(Cashier.email == payload.email, Cashier.is_active == True)
        .first()
    )

    if not user or not user.password_hash or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )

    access_token = create_access_token(
        data={"sub": str(user.id), "name": user.name, "role": user.role}
    )

    user_data = CashierResponse.model_validate(user).model_dump(mode="json")

    return {
        "success": True,
        "message": f"Welcome, {user.name}!",
        "data": {
            "access_token": access_token,
            "token_type": "bearer",
            "user": user_data,
        },
        "statusCode": 200,
    }


@router.get("/me")
def get_me(current_user: Cashier = Depends(get_current_user)):
    """Get the profile of the currently logged-in cashier."""
    user_data = CashierResponse.model_validate(current_user).model_dump(mode="json")
    return {
        "success": True,
        "message": "Profile retrieved",
        "data": user_data,
        "statusCode": 200,
    }


@router.post("/logout")
def logout(current_user: Cashier = Depends(get_current_user)):
    """Logout current authenticated cashier."""
    return {
        "success": True,
        "message": f"Cashier {current_user.name} logged out successfully.",
        "data": None,
        "statusCode": 200,
    }

