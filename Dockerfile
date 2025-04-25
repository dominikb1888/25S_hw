# -- Stage 1: Builder --
FROM alpine:3.19 AS builder

# Define exact versions
ENV PYTHON_VERSION=3.11.7-r1 \
    PIP_VERSION=23.3.2-r0 \
    LIBFFI_DEV_VERSION=3.4.4-r1 \
    OPENSSL_DEV_VERSION=3.1.5-r0 \
    MUSL_DEV_VERSION=1.2.4-r1 \
    BUILD_BASE_VERSION=0.5-r3

# Install system deps for Python + Poetry
RUN apk add --no-cache \
    python3=$PYTHON_VERSION \
    py3-pip=$PIP_VERSION \
    build-base=$BUILD_BASE_VERSION \
    libffi-dev=$LIBFFI_DEV_VERSION \
    openssl-dev=$OPENSSL_DEV_VERSION \
    musl-dev=$MUSL_DEV_VERSION \
    curl

# Install Poetry
ENV POETRY_VERSION=1.8.2 \
    POETRY_NO_INTERACTION=1 \
    POETRY_VIRTUALENVS_CREATE=false

RUN curl -sSL https://install.python-poetry.org | python3 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN poetry install --no-dev

COPY . .

# -- Stage 2: Runtime --
FROM alpine:3.19

# Runtime versions
ENV PYTHON_VERSION=3.11.7-r1 \
    PIP_VERSION=23.3.2-r0 \
    LIBFFI_VERSION=3.4.4-r1 \
    OPENSSL_VERSION=3.1.5-r0

# Install only runtime deps (exact versions)
RUN apk add --no-cache \
    python3=$PYTHON_VERSION \
    py3-pip=$PIP_VERSION \
    libffi=$LIBFFI_VERSION \
    openssl=$OPENSSL_VERSION

WORKDIR /app

COPY --from=builder . .

EXPOSE 8000

CMD ["python3", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]

