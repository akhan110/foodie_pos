# BiteFlow POS (`foodiepos`) — System Architecture & Knowledge Base

> **Single Source of Truth for Future Sessions**: This document contains everything needed to understand the BiteFlow POS codebase without re-analyzing the entire project. Any AI agent or developer opening this project on any machine can read this file and `AGENTS.md` to immediately know the complete state and next steps.

---

## 📌 1. Project Overview & Tech Stack

* **Application Name**: BiteFlow POS (`foodiepos`)
* **Target Platforms**: Desktop (Windows/macOS/Linux) & Tablet (Landscape orientation, minimum supported width: `900px`).
* **Frontend Framework**: Flutter (Dart SDK `>=3.9.0`)
* **State Management & Routing**: [GetX](https://pub.dev/packages/get) (`GetView`, `GetxController`, `GetPage`, `Bindings`, `GetBuilder`, `Obx`).
* **Network & HTTP Client**: `dio` (`Network` singleton service with defensive typed error handling, logging, and concurrency control).
* **Local Storage & Database**: 
  * `get_storage` (Key-value store initialized at app launch in [main.dart](file:///c:/Users/Akhan/Desktop/foodie_pos/foodiepos/lib/main.dart)).
  * `isar` & `isar_flutter_libs` (Offline-first local database for products and orders).
* **Backend Framework**: Python 3.10+ with **FastAPI**, **SQLAlchemy**, and **Pydantic v2**.
* **Cloud Database**: **Neon Serverless PostgreSQL** (AWS Singapore).
* **Authentication**: JWT Bearer Tokens (`python-jose`) + Native Bcrypt password & PIN hashing.
* **Connectivity**: `internet_connection_checker_plus` (`ConnectivityController` for live online/offline badge).

---

## 🗂️ 2. Directory Structure & File Map

```
foodiepos/
├── AGENTS.md                                   # Quick agent guidelines & system rules
├── PROJECT_OVERVIEW.md                         # This comprehensive knowledge base
├── lib/
│   ├── main.dart                               # App entry, GetStorage init, ThemeController injection, BiteFlowApp
│   ├── app/
│   │   ├── constants/assets_svg.dart           # Static paths to SVG icons
│   │   ├── routes/                             # AppRoutes & AppPages
│   │   ├── theme/                              # AppColors, AppTheme (light/dark), ThemeController
│   │   └── widgets/                            # SecondaryAppBar, SearchWidget, UnsupportedScreenView (<900px)
│   ├── models/
│   │   └── base_response_model.dart            # Generic defensive API envelope: { success, data, message, error }
│   ├── services/
│   │   └── network/                            # Production-grade Dio layer
│   │       ├── network.dart                    # Singleton client (apiRequest, auth headers, debounce, logging)
│   │       ├── network_config.dart             # API_BASE_URL, tokenProvider, timeouts
│   │       ├── api_exception.dart              # Typed ApiException (400, 401, 403, 404, 422, 500, network)
│   │       └── api_request_type.dart           # Enum: GET, POST, PUT, PATCH, DELETE
│   └── modules/
│       ├── login/                              # Responsive Split View + 4-dot PIN Keypad (1234)
│       ├── shell/                              # MainShellView (900px guard), SecondaryAppBar, SideNavigation
│       └── pos/                                # POS Root (ProductSection [Expanded] + CartSection [360px])
│           └── widgets/new_order/
│               ├── left_view_products/         # Header, ProductCard, ProductGrid
│               └── right_view_cart/            # 2-Tier overflow-proof CartItemTile, CartSection, OrderTypeTabs
│
└── backend/                                    # Python FastAPI Backend
    ├── requirements.txt                        # fastapi, uvicorn, sqlalchemy, psycopg2-binary, bcrypt, python-jose
    ├── .env                                    # DATABASE_URL (Neon Postgres), JWT_SECRET_KEY, ALGORITHM
    ├── .env.example                            # Template for environment variables
    └── app/
        ├── main.py                             # FastAPI entry point with CORS enabled
        ├── database.py                         # SQLAlchemy engine, session maker, get_db dependency
        ├── models.py                           # SQLAlchemy models: Cashier, Category, Product, Order, OrderItem
        ├── schemas.py                          # Pydantic schemas: PinLoginRequest, SignupRequest, TokenResponse, etc.
        ├── auth.py                             # Native bcrypt hashing + JWT create/verify functions
        └── routers/
            └── auth.py                         # /api/v1/auth/pin-login, signup, login, me
```

---

## 🐘 3. Database & Backend Architecture

### Cloud Database (Neon PostgreSQL)
* **Host**: AWS Singapore (`ap-southeast-1.aws.neon.tech`)
* **Database Name**: `neondb`
* **Seeded Tables**:
  1. `cashiers`: Cashiers/Users with hashed PINs (Default: Alex Khan, PIN `1234`).
  2. `categories`: Food categories (Burgers, Pizza, Chicken, Sides, Drinks, Desserts).
  3. `products`: Menu items with pricing, category FK, combo status, popularity flag.
  4. `orders`: POS transactions with order number, payment type, cashier FK, sync status.
  5. `order_items`: Order line items with quantity, unit price, and subtotal.

### Running the Backend Locally
```bash
cd backend
python -m venv venv
venv\Scripts\activate  # On Windows (or source venv/bin/activate on Linux/macOS)
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
* **Swagger UI / Interactive Docs**: `http://localhost:8000/docs`
* **Health Check**: `http://localhost:8000/health`

---

## 🎨 4. Key Design Rules & Conventions

1. **Responsive Proportions**:
   * Minimum POS breakpoint is **`900px`**. Any width below this automatically displays `UnsupportedScreenView`.
   * `NewOrderView` uses `Expanded(child: ProductSection())` on the left and `SizedBox(width: 360, child: CartSection())` on the right.
2. **Cart Item Tile Design**:
   * Always maintain the **2-tier layout** in `CartItemTile` (Top: thumbnail + title + remove button; Bottom: stepper + price). This guarantees zero horizontal overflow.
3. **Theming & Colors**:
   * Brand colors: `AppColors.primary` (`#FF6B35`), `AppColors.success` (`#12B76A`), `AppColors.error` (`#F04438`).
   * Surfaces & backgrounds: `theme.colorScheme.surface`, `theme.colorScheme.onSurface`, `theme.dividerColor`.

---

## 🔑 5. Authentication Details
* **PIN Authentication**: **`1234`**
* Keypad accepts numbers 0–9, backspace icon, checkmark icon, or the Login button.
* Backend Endpoint: `POST /api/v1/auth/pin-login` -> returns JWT token + cashier profile.

---

## 🚀 6. Next Implementation Steps

1. **Connect Flutter `LoginController` to Backend**:
   * Update `LoginController.verifyPin()` to call `Network.instance.apiRequest` at `POST /api/v1/auth/pin-login`.
   * Store token & cashier in `GetStorage` and navigate to `AppRoutes.pos`.
2. **Menu & Products Endpoints**:
   * Create `backend/app/routers/menu.py` for `GET /api/v1/menu/categories` and `GET /api/v1/menu/products`.
   * Bind Flutter `ProductSection` to fetch and display live menu items from the API with Isar offline fallback.
3. **Reactive POS Cart & Checkout**:
   * Wire `+ Add` button on `ProductCard` to reactive `PosController.cartItems`.
   * Reactive cart summary (subtotal, tax, discount, total).
   * Checkout & Sync: Save placed orders to Isar DB, then sync to `POST /api/v1/orders`.
