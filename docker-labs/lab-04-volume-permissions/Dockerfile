FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

COPY main.py ./

# Create non-root user for security
RUN useradd -m -u 1001 appuser

# BUG: Switching to non-root user but /app/data is owned by root
# The volume mount will be owned by root, and appuser can't write to it
USER appuser

CMD ["python", "main.py"]
