import os
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.orm import declarative_base, sessionmaker

load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://neondb_owner:npg_8xrIsF3PXOhQ@ep-rough-forest-b32j7r1m.c-4.ap-southeast-1.aws.neon.tech/neondb?sslmode=require",
)

# Render / SQLAlchemy standard: ensure 'postgresql://' instead of legacy 'postgres://'
if DATABASE_URL.startswith("postgres://"):
    DATABASE_URL = DATABASE_URL.replace("postgres://", "postgresql://", 1)

engine = create_engine(DATABASE_URL, pool_pre_ping=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def init_db_schema():
    """Ensure all required columns and tables exist in Neon PostgreSQL."""
    try:
        from sqlalchemy import text
        with engine.connect() as conn:
            conn.execute(
                text(
                    """
                    CREATE TABLE IF NOT EXISTS orders (
                        id VARCHAR(50) PRIMARY KEY,
                        order_number VARCHAR(20) NOT NULL,
                        order_type VARCHAR(30) NOT NULL DEFAULT 'Dine in',
                        status VARCHAR(30) NOT NULL DEFAULT 'Completed',
                        table_number VARCHAR(50) DEFAULT 'Table 1',
                        cashier_name VARCHAR(100) NOT NULL DEFAULT 'Akhan',
                        payment_method VARCHAR(50) NOT NULL DEFAULT 'Cash',
                        subtotal NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        tax NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        discount NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        total NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        amount_received NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        change_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
                    );
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_number VARCHAR(20);
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS order_type VARCHAR(30) DEFAULT 'Dine in';
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS status VARCHAR(30) DEFAULT 'Completed';
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS table_number VARCHAR(50) DEFAULT 'Table 1';
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS cashier_name VARCHAR(100) DEFAULT 'Akhan';
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50) DEFAULT 'Cash';
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS subtotal NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS tax NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS discount NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS total NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS amount_received NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS change_amount NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE orders ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP;

                    CREATE TABLE IF NOT EXISTS order_items (
                        id VARCHAR(50) PRIMARY KEY,
                        order_id VARCHAR(50) NOT NULL,
                        product_id VARCHAR(50),
                        product_name VARCHAR(150) NOT NULL,
                        product_image VARCHAR(255) DEFAULT 'assets/svg/products/burger.svg',
                        size VARCHAR(50) DEFAULT 'Regular',
                        addons VARCHAR(255),
                        quantity INTEGER NOT NULL DEFAULT 1,
                        unit_price NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        total_price NUMERIC(10, 2) NOT NULL DEFAULT 0.0
                    );
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS order_id VARCHAR(50);
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_id VARCHAR(50);
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_name VARCHAR(150);
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS product_image VARCHAR(255) DEFAULT 'assets/svg/products/burger.svg';
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS size VARCHAR(50) DEFAULT 'Regular';
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS addons VARCHAR(255);
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS quantity INTEGER DEFAULT 1;
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS unit_price NUMERIC(10, 2) DEFAULT 0.0;
                    ALTER TABLE order_items ADD COLUMN IF NOT EXISTS total_price NUMERIC(10, 2) DEFAULT 0.0;

                    CREATE TABLE IF NOT EXISTS shifts (
                        id VARCHAR(50) PRIMARY KEY,
                        cashier_id VARCHAR(50),
                        cashier_name VARCHAR(100) NOT NULL DEFAULT 'Akhan',
                        opening_float NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        closing_cash NUMERIC(10, 2),
                        expected_cash NUMERIC(10, 2),
                        cash_difference NUMERIC(10, 2),
                        total_sales NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        cash_sales NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        card_sales NUMERIC(10, 2) NOT NULL DEFAULT 0.0,
                        total_orders INTEGER NOT NULL DEFAULT 0,
                        status VARCHAR(30) NOT NULL DEFAULT 'open',
                        notes VARCHAR(500),
                        opened_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
                        closed_at TIMESTAMPTZ
                    );
                    ALTER TABLE shifts ADD COLUMN IF NOT EXISTS notes VARCHAR(500);

                    ALTER TABLE products ADD COLUMN IF NOT EXISTS sku VARCHAR(50);
                    ALTER TABLE products ADD COLUMN IF NOT EXISTS is_popular BOOLEAN DEFAULT FALSE;
                    ALTER TABLE products ADD COLUMN IF NOT EXISTS is_combo BOOLEAN DEFAULT FALSE;
                    ALTER TABLE products ADD COLUMN IF NOT EXISTS is_kitchen BOOLEAN DEFAULT TRUE;
                    ALTER TABLE products ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT TRUE;
                    """
                )
            )
            conn.commit()
    except Exception as e:
        print(f"Warning: init_db_schema encountered: {e}")


def get_db():
    """Dependency that yields a database session per request and closes it."""
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

