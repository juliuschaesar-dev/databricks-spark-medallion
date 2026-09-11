# 3.12, not 3.13: databricks-connect pins numpy<2, which has no Python 3.13 wheel.
FROM python:3.12-slim-bookworm

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

CMD ["pytest", "-v"]
