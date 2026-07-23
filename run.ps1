# =============================================================================
# Pipeline reproducible DE CERO para Windows (PowerShell nativo, sin WSL).
#
# Uso (en PowerShell, dentro de la carpeta del proyecto):
#   .\run.ps1
#
# Si PowerShell bloquea el script, ejecuta una vez:
#   Set-ExecutionPolicy -Scope Process Bypass
#
# NO necesitas nada preinstalado:
#   - Si falta 'uv'     -> se instala automaticamente (sin admin)
#   - Si falta 'quarto' -> se descarga el zip portable a .tools\ (sin admin)
#   - Si falta Python   -> uv lo descarga segun .python-version
# =============================================================================
$ErrorActionPreference = "Stop"

$QuartoVersion = "1.6.42"
$ToolsDir = Join-Path $PSScriptRoot ".tools"

function Say($msg) { Write-Host "`n==> $msg" -ForegroundColor Cyan }

# --- 0a. Bootstrap de uv ------------------------------------------------------
if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
    Say "uv no encontrado - instalandolo automaticamente (sin admin)"
    Invoke-RestMethod https://astral.sh/uv/install.ps1 | Invoke-Expression
    # El instalador deja uv en %USERPROFILE%\.local\bin
    $env:Path = "$env:USERPROFILE\.local\bin;$env:Path"
    if (-not (Get-Command uv -ErrorAction SilentlyContinue)) {
        throw "La instalacion de uv fallo. Instala manualmente: https://docs.astral.sh/uv/"
    }
}
Say "uv $(uv --version) listo"

# --- 0b. Bootstrap de Quarto (zip portable, sin admin) ------------------------
$QuartoLocal = Join-Path $ToolsDir "quarto-$QuartoVersion\bin"
if (Test-Path (Join-Path $QuartoLocal "quarto.exe")) {
    $env:Path = "$QuartoLocal;$env:Path"
}
if (-not (Get-Command quarto -ErrorAction SilentlyContinue)) {
    Say "Quarto no encontrado - descargando copia local en .tools\ (sin admin)"
    New-Item -ItemType Directory -Force -Path $ToolsDir | Out-Null
    $zip = Join-Path $ToolsDir "quarto.zip"
    $url = "https://github.com/quarto-dev/quarto-cli/releases/download/v$QuartoVersion/quarto-$QuartoVersion-win.zip"
    Invoke-WebRequest -Uri $url -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath (Join-Path $ToolsDir "quarto-$QuartoVersion") -Force
    Remove-Item $zip
    $env:Path = "$QuartoLocal;$env:Path"
    if (-not (Get-Command quarto -ErrorAction SilentlyContinue)) {
        throw "La instalacion de Quarto fallo. Instala manualmente: https://quarto.org/docs/get-started/"
    }
}
Say "Quarto $(quarto --version) listo"

# --- 1. Crear/sincronizar el ambiente con uv ---------------------------------
Say "Sincronizando ambiente con uv (uv sync)"
uv sync
if ($LASTEXITCODE -ne 0) { throw "uv sync fallo" }

# --- 2. Descargar la data -----------------------------------------------------
Say "Descargando dataset Palmer Penguins"
uv run python scripts/fetch_data.py
if ($LASTEXITCODE -ne 0) { throw "fetch_data fallo" }

# --- 3. Renderizar el reporte Quarto ------------------------------------------
Say "Renderizando report.qmd con Quarto"
uv run quarto render report.qmd
if ($LASTEXITCODE -ne 0) { throw "quarto render fallo" }

Say "Listo. Abre: practica-reproducibilidad\report.html"
Say "(por ejemplo:  start practica-reproducibilidad\report.html )"
