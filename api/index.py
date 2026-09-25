import os
import sys

current_dir = os.path.dirname(os.path.abspath(__file__))
if current_dir not in sys.path:
    sys.path.insert(0, current_dir)

from app.main import app as fastapi_app

async def app(scope, receive, send):
    if scope.get("type") == "http":
        headers = dict(scope.get("headers", []))
        # Vercel supplies the full original request URL in x-matched-path or x-vercel-matched-path
        matched = headers.get(b"x-matched-path") or headers.get(b"x-vercel-matched-path")
        if matched:
            path_str = matched.decode("utf-8")
            if "?" in path_str:
                path_str = path_str.split("?")[0]
            scope["path"] = path_str
            scope["raw_path"] = path_str.encode("utf-8")

    await fastapi_app(scope, receive, send)

handler = app
