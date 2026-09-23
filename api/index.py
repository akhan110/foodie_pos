import os
import sys

# Add backend directory to sys.path
backend_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "backend")
if os.path.exists(backend_path):
    sys.path.insert(0, os.path.abspath(backend_path))
else:
    sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from app.main import app

# Vercel ASGI entry point
handler = app
