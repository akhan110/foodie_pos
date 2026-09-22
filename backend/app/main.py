from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import Base, engine, init_db_schema
from .routers import auth, menu, orders, shifts, analytics

# Automatically create tables and migrate columns if not present
Base.metadata.create_all(bind=engine)
init_db_schema()

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

# Register routers
app.include_router(auth.router)
app.include_router(menu.router)
app.include_router(orders.router)
app.include_router(shifts.router)
app.include_router(analytics.router)

# Mount static uploads directory for serving product images
UPLOAD_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), "uploads")
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=UPLOAD_DIR), name="uploads")


@app.get("/")
def root():
    return {
        "success": True,
        "message": "BiteFlow POS Backend API is running smoothly!",
        "version": "1.0.0",
        "docs_url": "/docs",
    }


@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "biteflow-pos-backend"}
