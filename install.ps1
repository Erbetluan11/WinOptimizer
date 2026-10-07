# =====================================================================
# WinOptimizer v2.0 - Instalador e Inicializador
# Uso: irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
# =====================================================================
$ErrorActionPreference = "Stop"
$AppName = "WinOptimizer"
$Owner = "Erbetluan11"
$Repository = "WinOptimizer"
$Branch = "main"
$Version = "2.0.0"
$RawBaseUrl = "https://raw.githubusercontent.com/$Owner/$Repository/$Branch"

function Write-Banner {
    Clear-Host
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "                    WINOPTIMIZER v$Version" -ForegroundColor Cyan
    Write-Host "              Instalador e Inicializador Modular" -ForegroundColor DarkCyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Administrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Pause-WinOptimizer {
    Write-Host ""
    Read-Host "Pressione Enter para fechar"
}

function Download-ProjectFile {
    param([string]$RelativePath, [string]$DestinationPath)
    $DestinationFolder = Split-Path -Path $DestinationPath -Parent
    if (-not (Test-Path $DestinationFolder)) {
        New-Item -Path $DestinationFolder -ItemType Directory -Force | Out-Null
    }
    $NoCache = Get-Random
    $Url = "$RawBaseUrl/$RelativePath`?nocache=$NoCache"
    Invoke-WebRequest -Uri $Url -Headers @{ "User-Agent" = "$AppName-PowerShell"; "Cache-Control" = "no-cache" } -OutFile $DestinationPath -UseBasicParsing
    if (-not (Test-Path $DestinationPath)) { throw "Falha ao baixar: $RelativePath" }
    if ((Get-Item $DestinationPath).Length -lt 25) { throw "Arquivo vazio ou invalido: $RelativePath" }
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
    Write-Banner
    if (-not (Test-Administrator)) {
        Write-Host "[!] Abra o PowerShell como Administrador e execute novamente." -ForegroundColor Yellow
        Pause-WinOptimizer
        exit 1
    }
    $TempFolder = Join-Path $env:TEMP $AppName
    if (Test-Path $TempFolder) { Remove-Item -Path $TempFolder -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -Path $TempFolder -ItemType Directory -Force | Out-Null
    $ProjectFiles = @(
        "run.ps1", "modules/Core.ps1", "modules/Diagnostics.ps1", "modules/Backup.ps1",
        "modules/Profiles.ps1", "modules/Cleanup.ps1", "modules/Repair.ps1", "modules/Network.ps1",
        "modules/Reports.ps1", "modules/Restore.ps1", "config/tweaks.json"
    )
    Write-Host "[+] Baixando WinOptimizer v$Version..." -ForegroundColor Yellow
    foreach ($File in $ProjectFiles) {
        Write-Host "    Baixando: $File" -ForegroundColor DarkGray
        Download-ProjectFile -RelativePath $File -DestinationPath (Join-Path $TempFolder $File)
    }
    Write-Host "[+] Todos os arquivos foram baixados." -ForegroundColor Green
    Write-Host "[+] Iniciando WinOptimizer..." -ForegroundColor Cyan
    Start-Sleep -Milliseconds 600
    & powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $TempFolder "run.ps1")
}
catch {
    Write-Host ""; Write-Host "[ERRO] Nao foi possivel instalar ou iniciar o WinOptimizer." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Write-Host "Confira se todos os arquivos existem na branch '$Branch'." -ForegroundColor Yellow
}
finally { Pause-WinOptimizer }
