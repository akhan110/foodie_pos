import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))
# Sibling backend (when in /api)
p1 = os.path.abspath(os.path.join(current_dir, "..", "backend"))
# Child backend
p2 = os.path.abspath(os.path.join(current_dir, "backend"))
# Current directory
p3 = current_dir

for p in [p1, p2, p3]:
    if os.path.exists(p) and p not in sys.path:
        sys.path.insert(0, p)

from app.main import app

# Vercel ASGI entry point
handler = app
