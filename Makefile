.PHONY: all env data render clean

# Pipeline completo (equivale a: bash run.sh)
all:
	bash run.sh

# Solo crear/sincronizar el ambiente
env:
	uv sync

# Solo descargar la data
data: env
	uv run python scripts/fetch_data.py

# Solo renderizar (asume que la data ya existe)
render:
	uv run quarto render report.qmd

# Borrar productos generados (deja el repo como recién clonado)
clean:
	rm -rf practica-reproducibilidad .quarto report_files
