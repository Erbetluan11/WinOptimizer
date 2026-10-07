# =====================================================================
# WinOptimizer v2.1 Debloat Edition - Instalador modular
# Uso: irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
# =====================================================================
$ErrorActionPreference = "Stop"
$AppName = "WinOptimizer"
$Owner = "Erbetluan11"
$Repository = "WinOptimizer"
$Branch = "main"
$Version = "2.1.0"
$RawBaseUrl = "https://raw.githubusercontent.com/$Owner/$Repository/$Branch"

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Pause-WinOptimizer { Write-Host ""; Read-Host "Pressione Enter para fechar" }
function Download-ProjectFile {
    param([Parameter(Mandatory=$true)][string]$RelativePath,[Parameter(Mandatory=$true)][string]$DestinationPath)
    $folder = Split-Path -Path $DestinationPath -Parent
    if (-not (Test-Path $folder)) { New-Item -Path $folder -ItemType Directory -Force | Out-Null }
    $url = "$RawBaseUrl/$RelativePath`?nocache=$(Get-Random)"
    Invoke-WebRequest -Uri $url -Headers @{"User-Agent"="$AppName-PowerShell";"Cache-Control"="no-cache"} -OutFile $DestinationPath -UseBasicParsing
    if (-not (Test-Path $DestinationPath) -or (Get-Item $DestinationPath).Length -lt 25) { throw "Falha ou arquivo invalido: $RelativePath" }
}
try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Clear-Host
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "              WINOPTIMIZER v$Version - DEBLOAT EDITION" -ForegroundColor Cyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    if (-not (Test-Administrator)) { throw "Abra o PowerShell como Administrador e execute novamente." }
    $temp = Join-Path $env:TEMP $AppName
    if (Test-Path $temp) { Remove-Item $temp -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -Path $temp -ItemType Directory -Force | Out-Null
    $projectFiles = @(
        "run.ps1", "README.md", "modules/Core.ps1", "modules/Diagnostics.ps1", "modules/Backup.ps1", "modules/Profiles.ps1",
        "modules/Cleanup.ps1", "modules/Repair.ps1", "modules/Network.ps1", "modules/Reports.ps1", "modules/Restore.ps1",
        "modules/Debloat.ps1", "modules/Services.ps1", "modules/Apps.ps1", "config/tweaks.json", "config/debloat.json"
    )
    Write-Host "[+] Baixando arquivos..." -ForegroundColor Yellow
    foreach ($file in $projectFiles) { Write-Host "    $file" -ForegroundColor DarkGray; Download-ProjectFile $file (Join-Path $temp $file) }
    Write-Host "[+] Iniciando WinOptimizer..." -ForegroundColor Green
    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $temp "run.ps1")
} catch {
    Write-Host ""; Write-Host "[ERRO] $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Confira se todos os arquivos foram enviados para a branch '$Branch'." -ForegroundColor Yellow
} finally { Pause-WinOptimizer }
