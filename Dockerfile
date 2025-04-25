# -- Stage 1: Builder --
FROM alpine:3.19 AS builder

# Install system deps for Python + Poetry
RUN apk add --no-cache \
    python3~3.11 \
    py3-pip~23.3 \
    build-base \
    libffi-dev~3.4 \
    openssl-dev~3.1 \
    musl-dev~1.2 \
    curl

# Install Poetry
ENV POETRY_VERSION=1.8.2 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false

RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

WORKDIR .

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

COPY . .

# -- Stage 2: Runtime --
FROM alpine:3.19

# Install only runtime deps (exact versions)
RUN apk add --no-cache \
    python3~3.11 \
    py3-pip~23.3 \
    libffi-dev~3.4 \
    openssl-dev~3.1

WORKDIR .

COPY --from=builder . .

EXPOSE 8000

CMD ["python3", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

