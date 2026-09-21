from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .database import Base, engine
from .routers import auth

# Automatically create tables if not present
Base.metadata.create_all(bind=engine)

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

# Register routers
app.include_router(auth.router)


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
