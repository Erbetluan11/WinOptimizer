# =====================================================================
# WinOptimizer - Instalador e Inicializador
# Repositorio: https://github.com/Erbetluan11/WinOptimizer
#
# Execute no PowerShell como Administrador:
# irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
# =====================================================================

$ErrorActionPreference = "Stop"

$AppName    = "WinOptimizer"
$Owner      = "Erbetluan11"
$Repository = "WinOptimizer"
$Branch     = "main"
$Version    = "1.1.0"

$RawBaseUrl = "https://raw.githubusercontent.com/$Owner/$Repository/$Branch"
$RunUrl     = "$RawBaseUrl/run.ps1"

function Write-Banner {
    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    $AppName v$Version" -ForegroundColor Cyan
    Write-Host "            Instalador e Inicializador Seguro" -ForegroundColor DarkCyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Test-Administrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)

    return $Principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Pause-WinOptimizer {
    Write-Host ""
    Read-Host "Pressione Enter para fechar"
}

try {
    # Compatibilidade com HTTPS/TLS em Windows PowerShell 5.1.
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.ServicePointManager]::SecurityProtocol -bor `
        [Net.SecurityProtocolType]::Tls12

    Write-Banner

    if (-not (Test-Administrator)) {
        Write-Host "[!] Execute o PowerShell como Administrador." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Feche esta janela."
        Write-Host "2. Abra o Menu Iniciar e procure por PowerShell."
        Write-Host "3. Clique com o botao direito em Windows PowerShell."
        Write-Host "4. Selecione: Executar como administrador."
        Write-Host "5. Cole novamente o comando do WinOptimizer."

        Pause-WinOptimizer
        exit 1
    }

    $TempFolder = Join-Path $env:TEMP $AppName
    $RunFile = Join-Path $TempFolder "run.ps1"

    if (-not (Test-Path $TempFolder)) {
        New-Item -Path $TempFolder -ItemType Directory -Force | Out-Null
    }

    Write-Host "[+] Conectando ao repositorio..." -ForegroundColor Yellow

    $Headers = @{
        "User-Agent"    = "$AppName-PowerShell"
        "Cache-Control" = "no-cache"
    }

    # ${RunUrl} é essencial: delimita a variável antes do ? de query string.
    $NoCache = Get-Random
    $DownloadUrl = "${RunUrl}?nocache=$NoCache"

    Write-Host "[+] Baixando a versao mais recente..." -ForegroundColor Yellow

    Invoke-WebRequest `
        -Uri $DownloadUrl `
        -Headers $Headers `
        -OutFile $RunFile `
        -UseBasicParsing

    if (-not (Test-Path $RunFile)) {
        throw "O arquivo run.ps1 nao foi encontrado depois do download."
    }

    $RunFileSize = (Get-Item $RunFile).Length

    if ($RunFileSize -lt 500) {
        throw "O arquivo run.ps1 baixado esta vazio, incompleto ou invalido."
    }

    Write-Host "[+] Download concluido: $RunFileSize bytes." -ForegroundColor Green
    Write-Host "[+] Iniciando WinOptimizer..." -ForegroundColor Cyan

    Start-Sleep -Milliseconds 700

    # Abre o script baixado em processo separado e sem perfil do usuario.
    # Bypass vale somente para este processo; nao muda a configuracao permanente.
    & powershell.exe `
        -NoLogo `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $RunFile

    if ($LASTEXITCODE -ne 0 -and $null -ne $LASTEXITCODE) {
        Write-Host ""
        Write-Host "[!] O WinOptimizer encerrou com codigo: $LASTEXITCODE" -ForegroundColor Yellow
    }
}
catch {
    Write-Host ""
    Write-Host "[ERRO] Nao foi possivel iniciar o WinOptimizer." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "Confira se run.ps1 existe na raiz da branch '$Branch'." -ForegroundColor Yellow
}
finally {
    Pause-WinOptimizer
}
