$flutter = Join-Path $PSScriptRoot "tools\\flutter\\bin\\flutter.bat"

if (-not (Test-Path $flutter)) {
  Write-Error "No se encontro Flutter en tools/flutter. Instala o extrae el SDK primero."
  exit 1
}

& $flutter @args
exit $LASTEXITCODE

