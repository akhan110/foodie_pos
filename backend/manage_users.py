"""Utility script to manage users, reset/change PINs, and clean dummy users."""
import sys
from app.database import SessionLocal
from app.models import Cashier

def list_users():
    db = SessionLocal()
    users = db.query(Cashier).all()
    print("\n--- Current Cashiers & Users ---")
    for u in users:
        print(f"ID: {u.id} | Name: {u.name} | PIN: {u.pin} | Role: {u.role} | Store: {u.store_name} | Email: {u.email}")
    db.close()

def set_pin(user_email_or_name: str, new_pin: str):
    db = SessionLocal()
    user = db.query(Cashier).filter(
        (Cashier.email == user_email_or_name) | (Cashier.name == user_email_or_name)
    ).first()
    if not user:
        print(f"User '{user_email_or_name}' not found.")
        db.close()
        return
    user.pin = new_pin.strip()
    db.commit()
    print(f"✅ PIN for {user.name} updated to: {user.pin}")
    db.close()

def clean_dummy_users():
    db = SessionLocal()
    # Keep main admin/Alex Khan, delete any dummy/test users
    deleted = db.query(Cashier).filter(Cashier.name.ilike('%test%') | Cashier.email.ilike('%dummy%')).delete(synchronize_session=False)
    db.commit()
    print(f"🧹 Cleaned {deleted} dummy user records.")
    db.close()

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] == "list":
        list_users()
    elif len(sys.argv) > 3 and sys.argv[1] == "setpin":
        set_pin(sys.argv[2], sys.argv[3])
    elif len(sys.argv) > 1 and sys.argv[1] == "clean":
        clean_dummy_users()
    else:
        list_users()
