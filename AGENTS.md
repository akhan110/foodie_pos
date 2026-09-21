# BiteFlow POS (`foodiepos`) — Agent Context & Master Guide

> **Notice to AI Agents**: You are working on **BiteFlow POS**, a full-stack, offline-first Point of Sale application. Read this file first to understand the entire architecture, current progress, database setup, and next tasks.

---

## 🏗️ 1. Complete Architecture Summary

| Layer | Technology | Details |
|---|---|---|
| **Frontend App** | Flutter (Dart `>=3.9.0`) | Fast-food POS targeting Desktop (Windows/macOS/Linux) and Tablet Landscape (`>=900px`). |
| **State & Routes** | GetX | `GetView`, `GetPage`, `Bindings`, `ThemeController`, `PosController`, `LoginController`. |
| **HTTP Client** | Dio (`Network` Singleton) | Located in `lib/services/network/`. Typed error handling (`ApiException`), `BaseResponseModel<T>`, JWT auto-attachment. |
| **Local Storage** | `get_storage` + `isar` | `get_storage` for settings & tokens; `isar` for offline products/orders cache. |
| **Backend API** | Python 3.10+ & FastAPI | Located in `backend/`. SQLAlchemy ORM, Pydantic v2 schemas, CORS enabled. |
| **Cloud Database** | Neon PostgreSQL | Serverless Postgres hosted on AWS Singapore (`neondb`). |
| **Auth System** | Bcrypt + JWT (`python-jose`)| Cashier PIN hashing (`1234`) and JWT Bearer token generation. |

---

## 📌 2. What Has Been Completed

1. **Flutter Login Screen (`LoginView` & `LoginController`)**:
   - Clean left branding banner (burger graphic removed).
   - On-screen numeric keypad (`0–9`, backspace, submit) with dynamic 4-dot PIN indicator.
   - PIN `1234` navigates to `AppRoutes.pos`.
2. **POS Screen & Layout (`NewOrderView` & `CartItemTile`)**:
   - `< 900px` screen width guard (`UnsupportedScreenView`).
   - `ProductSection` is `Expanded`, `CartSection` is fixed width `360px`.
   - **CartItemTile 2-tier layout** (Top: image + title + delete; Bottom: stepper + price) — **strictly prevents horizontal pixel overflow**.
3. **Dio Networking Layer (`lib/services/network/`)**:
   - Production-grade HTTP singleton, typed `ApiException`, 10/10 unit tests passing.
4. **Neon Cloud Database**:
   - Tables created & seeded: `cashiers` (PIN `1234`), `categories`, `products` (10 items), `orders`, `order_items`.
5. **FastAPI Backend (`backend/`)**:
   - `POST /api/v1/auth/pin-login` (tested live 200 OK with `1234`).
   - `POST /api/v1/auth/signup`, `POST /api/v1/auth/login`, `GET /api/v1/auth/me`.

---

## ⚙️ 3. How to Run on Any Computer

### Running the Backend
```bash
cd backend
python -m venv venv
venv\Scripts\activate          # Windows (or source venv/bin/activate on Mac/Linux)
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
- API Docs: `http://localhost:8000/docs`
- Health: `http://localhost:8000/health`

### Running the Flutter App
```bash
flutter pub get
flutter run -d windows         # or chrome / macos / linux
```

---

## 🎯 4. Critical Design & Code Rules for Agents

1. **Layout Integrity**:
   - Never place cart items in a single wide row. Always keep the 2-tier structure in `CartItemTile` to prevent tablet overflow.
   - Screen breakpoint is `900px`.
2. **Theming**:
   - Never hardcode colors. Use `AppColors.primary` (`#FF6B35`) or `Theme.of(context).colorScheme`.
3. **Error Handling**:
   - All network calls must return `BaseResponseModel<T>` or handle `ApiException`.

---

## 🚀 5. Next Tasks to Implement

1. **Connect Flutter Login to FastAPI**:
   - In `LoginController.verifyPin()`, call `POST /api/v1/auth/pin-login` via `Network.instance.apiRequest`.
   - Store JWT token and cashier info in `GetStorage` and navigate to `AppRoutes.pos`.
2. **Menu Endpoints (`backend/app/routers/menu.py`)**:
   - `GET /api/v1/menu/categories` and `GET /api/v1/menu/products`.
   - Connect Flutter `ProductSection` to fetch live products with Isar offline caching.
3. **Cart & Checkout Logic**:
   - Reactive cart state (`PosController.cartItems`).
   - Wire `+ Add` button on `ProductCard` to add items to cart.
   - Implement checkout and order sync with `POST /api/v1/orders`.
