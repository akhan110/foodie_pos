from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware

from .database import Base, engine, init_db_schema
from .routers import auth, menu, orders, shifts, analytics, deals, system

# Automatically create tables and migrate columns if not present
try:
    Base.metadata.create_all(bind=engine)
    init_db_schema()
except Exception as e:
    print(f"Warning: Database initialization on startup encountered: {e}")

app = FastAPI(
    title="BiteFlow POS API",
    description="Backend API for BiteFlow Fast-Food Point of Sale System",
    version="1.0.0",
)

# Enable CORS for Flutter Web, Desktop, Mobile, and Localhost
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

import os
from fastapi.staticfiles import StaticFiles

# Register all routers under standard /api/v1 and serverless stripped /v1 prefixes
ROUTERS_MAP = [
    (auth.router, "/auth"),
    (menu.router, "/menu"),
    (orders.router, "/orders"),
    (shifts.router, "/shifts"),
    (analytics.router, "/analytics"),
    (deals.router, "/deals"),
    (system.router, "/system"),
]

for r, path_segment in ROUTERS_MAP:
    # 1. Full standard prefix: /api/v1/auth
    app.include_router(r, prefix=f"/api/v1{path_segment}")
    # 2. Vercel serverless stripped prefix: /v1/auth
    app.include_router(r, prefix=f"/v1{path_segment}")
    # 3. Direct api prefix: /api/auth
    app.include_router(r, prefix=f"/api{path_segment}")
    # 4. Short prefix: /auth
    app.include_router(r, prefix=path_segment)

# Mount static uploads directory for serving product images
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
try:
    os.makedirs(UPLOAD_DIR, exist_ok=True)
except OSError:
    UPLOAD_DIR = "/tmp/uploads"
    os.makedirs(UPLOAD_DIR, exist_ok=True)

if os.path.exists(UPLOAD_DIR):
    app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")


@app.get("/")
@app.get("/api")
@app.get("/api/")
def root():
    return {
        "success": True,
        "message": "BiteFlow POS Backend API is running smoothly!",
        "version": "1.0.0",
        "docs_url": "/docs",
    }


@app.get("/health")
@app.get("/api/health")
@app.get("/v1/health")
@app.get("/api/v1/health")
def health_check():
    return {"status": "healthy", "service": "biteflow-pos-backend"}


