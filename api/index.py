import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

from app.main import app

# ASGI Middleware to restore the true requested path from Vercel's x-matched-path header
class VercelPathFixMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        if scope.get("type") == "http":
            headers = dict(scope.get("headers", []))
            
            # Vercel always attaches the original client URL path in x-matched-path
            matched = headers.get(b"x-matched-path") or headers.get(b"x-vercel-matched-path")
            if matched:
                path_str = matched.decode("utf-8")
                # Remove query parameters if present
                if "?" in path_str:
                    path_str = path_str.split("?")[0]
                scope["path"] = path_str
                scope["raw_path"] = path_str.encode("utf-8")

        await self.app(scope, receive, send)

app.add_middleware(VercelPathFixMiddleware)

handler = app
