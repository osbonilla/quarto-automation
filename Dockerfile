# =============================================================================
# Imagen reproducible: Python 3.12 + uv + Quarto + el pipeline completo.
# Uso directo:
#   docker compose up --build
# o manual:
#   docker build -t repro-penguins .
#   docker run --rm -v "$(pwd)/practica-reproducibilidad:/app/practica-reproducibilidad" repro-penguins
# El report.html aparece en ./practica-reproducibilidad/ de tu maquina.
# =============================================================================
FROM python:3.12-slim

ARG QUARTO_VERSION=1.6.42

# Herramientas de sistema minimas
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# uv: copiado desde la imagen oficial de Astral (version fijada = reproducible)
COPY --from=ghcr.io/astral-sh/uv:0.9 /uv /usr/local/bin/uv

# Quarto (version fijada)
RUN curl -LsSf -o /tmp/quarto.deb \
      "https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb" \
    && apt-get update && apt-get install -y /tmp/quarto.deb \
    && rm /tmp/quarto.deb && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1) Solo los archivos de dependencias primero -> cachea la capa de uv sync
COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --frozen

# 2) El resto del proyecto
COPY _quarto.yml report.qmd ./
COPY scripts/ scripts/

# Al ejecutar el contenedor: data + render (el ambiente ya esta instalado)
CMD ["sh", "-c", "uv run python scripts/fetch_data.py && uv run quarto render report.qmd && echo 'Listo: practica-reproducibilidad/report.html'"]
