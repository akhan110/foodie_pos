# BiteFlow POS — FastAPI Backend

FastAPI backend connected to Neon PostgreSQL for the BiteFlow POS system.

## 🚀 Quick Start (Local Run)

### 1. Install Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Run the Development Server
```bash
uvicorn app.main:app --reload --port 8000
```

### 3. Interactive API Documentation
Open your browser and visit:
* **Swagger UI**: [http://localhost:8000/docs](http://localhost:8000/docs)
* **ReDoc**: [http://localhost:8000/redoc](http://localhost:8000/redoc)

---

## 🔑 Authentication Endpoints (Step 1)

* `POST /api/v1/auth/pin-login` — Fast-food cashier login using 4-digit PIN (e.g. `1234`).
* `POST /api/v1/auth/signup` — Create a new cashier / staff account.
* `POST /api/v1/auth/login` — Email & password login for managers.
* `GET /api/v1/auth/me` — Protected endpoint to retrieve authenticated cashier profile.
