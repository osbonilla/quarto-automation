# Visualización de Datos Reproducible — Python + Quarto + uv

Pipeline totalmente automatizado que reproduce el análisis del dataset
**Palmer Penguins**: exploración (EDA con Altair), figura explicativa final,
control de aleatoriedad con seeds, y un reporte HTML reproducible generado
con **Quarto**. Las dependencias se gestionan con [**uv**](https://docs.astral.sh/uv/)
(no se usa `requirements.txt`).

Al ejecutar el pipeline se crea automáticamente la subcarpeta
`practica-reproducibilidad/` con la data descargada, las figuras y el
reporte final:

```
practica-reproducibilidad/
├── data/
│   └── penguins.csv
├── figures/
└── report.html
```

## Requisitos previos

Solo necesitas dos herramientas instaladas en tu sistema:

| Herramienta | Instalación |
|---|---|
| [uv](https://docs.astral.sh/uv/getting-started/installation/) | `curl -LsSf https://astral.sh/uv/install.sh \| sh` |
| [Quarto](https://quarto.org/docs/get-started/) | Descargar desde https://quarto.org/docs/get-started/ |

> No necesitas instalar Python manualmente: `uv` descarga y fija la versión
> correcta según `.python-version`. Tampoco necesitas crear ni activar
> ambientes virtuales a mano.

Verifica que ambas estén disponibles:

```bash
uv --version
quarto --version
```

## Ejecución (un solo comando)

```bash
git clone https://github.com/<tu-usuario>/repro-penguins-quarto.git
cd repro-penguins-quarto
bash run.sh
```

Eso es todo. El script `run.sh` hace, en orden:

1. `uv sync` — crea el ambiente virtual e instala las dependencias exactas
   registradas en `uv.lock` (pandas, altair, numpy, jupyter).
2. Descarga `penguins.csv` desde la fuente pública y lo guarda en
   `practica-reproducibilidad/data/`.
3. `quarto render report.qmd` — ejecuta todo el código Python y genera
   `practica-reproducibilidad/report.html` (autocontenido, con
   `embed-resources: true`) junto con las figuras en
   `practica-reproducibilidad/figures/`.

Alternativa con Make:

```bash
make all      # equivale a bash run.sh
make clean    # borra los productos generados
```

Abre el resultado en tu navegador:

```bash
open practica-reproducibilidad/report.html        # macOS
xdg-open practica-reproducibilidad/report.html    # Linux
start practica-reproducibilidad\report.html       # Windows
```

## Estructura del repositorio

```
repro-penguins-quarto/
├── README.md                  # Este archivo
├── pyproject.toml             # Dependencias del proyecto (gestionadas por uv)
├── uv.lock                    # Lockfile: versiones exactas para reproducibilidad
├── .python-version            # Versión de Python fijada
├── run.sh                     # Pipeline completo en un solo comando
├── Makefile                   # Targets: all / render / clean
├── scripts/
│   └── fetch_data.py          # Descarga la data a practica-reproducibilidad/data/
├── report.qmd                 # Fuente Quarto: narrativa + código ejecutable
├── _quarto.yml                # Configuración del proyecto Quarto
└── practica-reproducibilidad/ # ← Generada automáticamente por el pipeline
```

## Reproducibilidad

- **Dependencias fijadas:** `uv.lock` registra las versiones exactas de cada
  paquete; cualquier persona que clone el repo obtiene el mismo ambiente.
- **Rutas relativas:** todo el código usa rutas relativas al repo; no hay que
  modificar nada para ejecutarlo en otra máquina.
- **Seeds fijados:** toda operación aleatoria (muestreo, jitter) usa
  `random_state=42` / `np.random.seed(42)`, de modo que dos renders del mismo
  reporte producen resultados idénticos.
- **Data automática:** la data no requiere pasos manuales; se descarga desde
  su fuente pública en cada ejecución (y queda versionada en
  `practica-reproducibilidad/data/` para inspección).
- **Un solo comando:** el reporte completo se regenera desde cero con
  `bash run.sh` — ninguna figura se edita a mano.

## Test de pares (peer test)

Para validar la reproducibilidad, otra persona debe poder:

1. Clonar el repositorio.
2. Ejecutar `bash run.sh` sin modificar ningún archivo.
3. Obtener el mismo `report.html` con las mismas figuras y los mismos
   valores muestreados.

| Criterio | ✔ |
|---|---|
| El proyecto contiene la data o instrucciones claras para obtenerla | ☐ |
| Todas las rutas son relativas | ☐ |
| El reporte se renderiza sin modificar código | ☐ |
| Las figuras se generan automáticamente | ☐ |
| Hay seeds definidos donde hay aleatoriedad | ☐ |
| Las dependencias están documentadas (pyproject.toml + uv.lock) | ☐ |
| El README explica claramente instalación y ejecución | ☐ |

## Personalizar el reporte

Edita `report.qmd` (secciones, texto, charts) y vuelve a ejecutar:

```bash
bash run.sh
# o solo el render, si la data ya existe:
uv run quarto render report.qmd
```

## Créditos

- Dataset: **Palmer Penguins** — Dr. Kristen Gorman, Palmer Station LTER.
- Principios de reproducibilidad basados en Claus O. Wilke,
  *Fundamentals of Data Visualization*, cap. 28.