# Script para renombrar imágenes en images/artshow/ a formato artshow-X.jpg
# Ejecutar desde PowerShell: .\rename-artshow-images.ps1

$artshowFolder = "images\artshow"
$extensions = @("*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif")

# Verificar que la carpeta existe
if (-not (Test-Path $artshowFolder)) {
    Write-Host "Error: La carpeta $artshowFolder no existe." -ForegroundColor Red
    exit
}

# Obtener todas las imágenes
$images = Get-ChildItem -Path $artshowFolder -File | Where-Object { $extensions -contains "*$($_.Extension)" -or $_.Extension -match '\.(jpg|jpeg|png|webp|gif)$' } | Sort-Object CreationTime

if ($images.Count -eq 0) {
    Write-Host "No se encontraron imágenes en $artshowFolder" -ForegroundColor Yellow
    exit
}

Write-Host "Encontradas $($images.Count) imágenes. Renombrando..." -ForegroundColor Green

# Crear carpeta temporal para evitar conflictos
$tempFolder = "$artshowFolder\_temp_rename"
New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null

# Mover todas las imágenes a la carpeta temporal primero
$counter = 1
foreach ($image in $images) {
    $extension = $image.Extension
    $newName = "artshow-$counter$extension"
    $tempPath = Join-Path $tempFolder $newName
    Move-Item -Path $image.FullName -Destination $tempPath -Force
    Write-Host "  Preparando: $($image.Name) -> $newName" -ForegroundColor Cyan
    $counter++
}

# Mover de vuelta a la carpeta original
$counter = 1
$tempImages = Get-ChildItem -Path $tempFolder -File | Sort-Object Name
foreach ($image in $tempImages) {
    $extension = $image.Extension
    $newName = "artshow-$counter$extension"
    $finalPath = Join-Path $artshowFolder $newName
    Move-Item -Path $image.FullName -Destination $finalPath -Force
    Write-Host "  Renombrado: $newName" -ForegroundColor Green
    $counter++
}

# Eliminar carpeta temporal
Remove-Item -Path $tempFolder -Force

Write-Host "`n¡Completado! $($images.Count) imágenes renombradas." -ForegroundColor Green
Write-Host "Las imágenes ahora se llaman: artshow-1, artshow-2, artshow-3, etc." -ForegroundColor Green

