# Use lightweight official Python runtime
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Set environment variables:
# - PYTHONDONTWRITEBYTECODE: Prevents Python from writing pyc files to disk
# - PYTHONUNBUFFERED: Prevents Python from buffering stdout/stderr for real-time logs
# - PORT: Default port 8000 (cloud hosts like Render/Railway pass their own $PORT)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8000

# Install system dependencies if required for database drivers
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Ensure uploads directory exists
RUN mkdir -p /app/uploads

# Expose the API port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:${PORT}/health || exit 1

# Start Uvicorn bound to 0.0.0.0 and dynamic $PORT
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT}"]
