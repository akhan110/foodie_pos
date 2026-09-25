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

try:
    from app.main import app
    handler = app
except Exception as e:
    import traceback
    err_trace = traceback.format_exc()
    print("FATAL ERROR IN VERCEL SERVERLESS APP IMPORT:\n", err_trace)

    # Fallback minimal app to expose the exact error to HTTP clients
    from fastapi import FastAPI
    from fastapi.responses import JSONResponse
    from fastapi.middleware.cors import CORSMiddleware

    fallback_app = FastAPI(title="Error Diagnostic")
    fallback_app.add_middleware(
        CORSMiddleware,
        allow_origins=["*"],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    @fallback_app.api_route("/{full_path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"])
    async def diagnostic_handler(full_path: str):
        return JSONResponse(
            status_code=500,
            content={
                "success": False,
                "error": "Serverless Function Startup Failed",
                "details": err_trace.splitlines(),
            }
        )

    handler = fallback_app
