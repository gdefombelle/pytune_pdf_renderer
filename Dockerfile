# ====== BUILD ======
FROM mcr.microsoft.com/playwright/python:v1.58.0-jammy AS builder

RUN pip install uv

WORKDIR /app

COPY pyproject.toml .
COPY app ./app

RUN uv sync --no-dev


# ====== RUNTIME ======
FROM mcr.microsoft.com/playwright/python:v1.58.0-jammy

WORKDIR /app
COPY --from=builder /app /app

EXPOSE 8010

CMD ["/app/.venv/bin/uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8011"]