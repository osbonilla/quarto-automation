#!/usr/bin/env bash
# =============================================================================
# Pipeline reproducible DE CERO: bootstrap de herramientas -> ambiente (uv)
# -> data -> render Quarto.
#
# Uso:  bash run.sh
#
# NO necesitas tener nada preinstalado salvo bash + curl (o wget) + tar:
#   - Si falta 'uv'     -> se instala automáticamente (sin sudo, en ~/.local/bin)
#   - Si falta 'quarto' -> se descarga localmente en .tools/ dentro del proyecto
# =============================================================================
set -euo pipefail

say()  { printf "\n\033[1;34m==> %s\033[0m\n" "$*"; }
warn() { printf "\033[1;33m%s\033[0m\n" "$*"; }

QUARTO_VERSION="1.6.42"
TOOLS_DIR="$(pwd)/.tools"

# Descargador portable: usa curl o wget, lo que exista
fetch() { # fetch <url> <output>
  if command -v curl >/dev/null 2>&1; then curl -LsSf "$1" -o "$2";
  elif command -v wget >/dev/null 2>&1; then wget -q "$1" -O "$2";
  else echo "ERROR: se necesita 'curl' o 'wget'."; exit 1; fi
}

# --- 0a. Bootstrap de uv ------------------------------------------------------
if ! command -v uv >/dev/null 2>&1; then
  say "uv no encontrado — instalándolo automáticamente (sin sudo)"
  if command -v curl >/dev/null 2>&1; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
  else
    wget -qO- https://astral.sh/uv/install.sh | sh
  fi
  # El instalador deja uv en ~/.local/bin (o ~/.cargo/bin en versiones viejas)
  export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"
  command -v uv >/dev/null 2>&1 || { echo "ERROR: la instalación de uv falló."; exit 1; }
fi
say "uv $(uv --version | awk '{print $2}') listo"

# --- 0b. Bootstrap de Quarto --------------------------------------------------
# Si ya hay una copia local en .tools/, úsala.
if [ -x "$TOOLS_DIR/quarto-$QUARTO_VERSION/bin/quarto" ]; then
  export PATH="$TOOLS_DIR/quarto-$QUARTO_VERSION/bin:$PATH"
fi

if ! command -v quarto >/dev/null 2>&1; then
  say "Quarto no encontrado — descargando copia local en .tools/ (sin sudo)"
  OS="$(uname -s)"; ARCH="$(uname -m)"
  case "$OS-$ARCH" in
    Linux-x86_64)  PKG="quarto-$QUARTO_VERSION-linux-amd64.tar.gz" ;;
    Linux-aarch64) PKG="quarto-$QUARTO_VERSION-linux-arm64.tar.gz" ;;
    Darwin-*)      PKG="quarto-$QUARTO_VERSION-macos.tar.gz" ;;
    *)
      warn "Sistema no soportado para instalación automática ($OS $ARCH)."
      warn "Instala Quarto manualmente desde: https://quarto.org/docs/get-started/"
      warn "(En Windows usa el instalador .msi y vuelve a ejecutar este script en Git Bash.)"
      exit 1 ;;
  esac
  mkdir -p "$TOOLS_DIR"
  URL="https://github.com/quarto-dev/quarto-cli/releases/download/v$QUARTO_VERSION/$PKG"
  fetch "$URL" "$TOOLS_DIR/$PKG"
  tar -xzf "$TOOLS_DIR/$PKG" -C "$TOOLS_DIR"
  rm -f "$TOOLS_DIR/$PKG"
  export PATH="$TOOLS_DIR/quarto-$QUARTO_VERSION/bin:$PATH"
  command -v quarto >/dev/null 2>&1 || { echo "ERROR: la instalación de Quarto falló."; exit 1; }
fi
say "Quarto $(quarto --version) listo"

# --- 1. Crear/sincronizar el ambiente con uv ---------------------------------
# uv también descarga la versión de Python fijada en .python-version si falta.
say "Sincronizando ambiente con uv (uv sync)"
uv sync

# --- 2. Descargar la data -----------------------------------------------------
say "Descargando dataset Palmer Penguins"
uv run python scripts/fetch_data.py

# --- 3. Renderizar el reporte Quarto ------------------------------------------
say "Renderizando report.qmd con Quarto"
uv run quarto render report.qmd

say "Listo ✔  Abre: practica-reproducibilidad/report.html"
