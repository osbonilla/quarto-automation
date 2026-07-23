"""Descarga el dataset Palmer Penguins a practica-reproducibilidad/data/.

Se ejecuta automáticamente desde run.sh (o `make all`) con:
    uv run python scripts/fetch_data.py

Idempotente: si el archivo ya existe, no lo vuelve a descargar
(usa --force para forzar la descarga).
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path

import pandas as pd

PENGUINS_URL = (
    "https://raw.githubusercontent.com/CarlaGeovanna/"
    "datasets_public/refs/heads/main/penguins.csv"
)

# Rutas relativas a la raíz del repo (este script vive en scripts/)
REPO_ROOT = Path(__file__).resolve().parent.parent
DATA_DIR = REPO_ROOT / "practica-reproducibilidad" / "data"
DATA_FILE = DATA_DIR / "penguins.csv"


def main() -> int:
    parser = argparse.ArgumentParser(description="Descarga penguins.csv")
    parser.add_argument(
        "--force", action="store_true",
        help="Vuelve a descargar aunque el archivo ya exista",
    )
    args = parser.parse_args()

    DATA_DIR.mkdir(parents=True, exist_ok=True)
    (REPO_ROOT / "practica-reproducibilidad" / "figures").mkdir(
        parents=True, exist_ok=True
    )

    if DATA_FILE.exists() and not args.force:
        print(f"[fetch_data] Ya existe: {DATA_FILE.relative_to(REPO_ROOT)} (usa --force para re-descargar)")
        return 0

    print(f"[fetch_data] Descargando {PENGUINS_URL} ...")
    penguins = pd.read_csv(PENGUINS_URL)

    expected_cols = {"species", "island", "body_mass_g", "flipper_length_mm"}
    missing = expected_cols - set(penguins.columns)
    if missing:
        print(f"[fetch_data] ERROR: faltan columnas esperadas: {missing}", file=sys.stderr)
        return 1

    penguins.to_csv(DATA_FILE, index=False)
    print(f"[fetch_data] OK: {len(penguins)} filas -> {DATA_FILE.relative_to(REPO_ROOT)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
