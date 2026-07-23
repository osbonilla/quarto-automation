#!/usr/bin/env bash
# =============================================================================
# Pipeline reproducible: ambiente (uv) -> data -> render Quarto
# Uso:  bash run.sh
# =============================================================================
set -euo pipefail

say() { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }

# --- 0. Verificar herramientas del sistema ----------------------------------
command -v uv >/dev/null 2>&1 || {
  echo "ERROR: 'uv' no está instalado."
  echo "Instálalo con:  curl -LsSf https://astral.sh/uv/install.sh | sh"
  exit 1
}
command -v quarto >/dev/null 2>&1 || {
  echo "ERROR: 'quarto' no está instalado."
  echo "Descárgalo desde: https://quarto.org/docs/get-started/"
  exit 1
}

# --- 1. Crear/sincronizar el ambiente con uv --------------------------------
say "Sincronizando ambiente con uv (uv sync)"
uv sync

# --- 2. Descargar la data ----------------------------------------------------
say "Descargando dataset Palmer Penguins"
uv run python scripts/fetch_data.py

# --- 3. Renderizar el reporte Quarto -----------------------------------------
# 'uv run' garantiza que Quarto use el Python del ambiente del proyecto.
say "Renderizando report.qmd con Quarto"
uv run quarto render report.qmd

say "Listo ✔  Abre: practica-reproducibilidad/report.html"
