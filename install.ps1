# ============================================================
# WinOptimizer - Instalador e Inicializador
# Repositorio: https://github.com/Erbetluan11/WinOptimizer
#
# Execute no PowerShell como Administrador:
# irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex
# ============================================================

$ErrorActionPreference = "Stop"

$AppName    = "WinOptimizer"
$Owner      = "Erbetluan11"
$Repository = "WinOptimizer"
$Branch     = "main"
$Version    = "1.0.0"

$RawBaseUrl = "https://raw.githubusercontent.com/$Owner/$Repository/$Branch"
$RunUrl     = "$RawBaseUrl/run.ps1"

function Write-Banner {
    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                    $AppName v$Version" -ForegroundColor Cyan
    Write-Host "             Instalador e Inicializador" -ForegroundColor DarkCyan
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
    [Net.ServicePointManager]::SecurityProtocol = `
        [Net.ServicePointManager]::SecurityProtocol -bor `
        [Net.SecurityProtocolType]::Tls12

    Write-Banner

    if (-not (Test-Administrator)) {
        Write-Host "[!] Abra o PowerShell como Administrador antes de executar." -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1. Feche esta janela." -ForegroundColor White
        Write-Host "2. Pesquise por PowerShell no Menu Iniciar." -ForegroundColor White
        Write-Host "3. Clique com o botao direito e escolha:" -ForegroundColor White
        Write-Host "   Executar como administrador" -ForegroundColor Cyan
        Write-Host "4. Execute o comando do WinOptimizer novamente." -ForegroundColor White

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
        "User-Agent" = "$AppName-PowerShell"
        "Cache-Control" = "no-cache"
    }

    Write-Host "[+] Baixando a versao mais recente..." -ForegroundColor Yellow

    $NoCache = Get-Random

    # Corrigido: ${RunUrl} deixa claro onde a variavel termina.
    $DownloadUrl = "${RunUrl}?nocache=$NoCache"

    Write-Host "[+] URL: $DownloadUrl" -ForegroundColor DarkGray

    Invoke-WebRequest `
        -Uri $DownloadUrl `
        -Headers $Headers `
        -OutFile $RunFile `
        -UseBasicParsing

    if (-not (Test-Path $RunFile)) {
        throw "O arquivo run.ps1 nao foi encontrado apos o download."
    }

    $RunFileSize = (Get-Item $RunFile).Length

    if ($RunFileSize -lt 100) {
        throw "O arquivo run.ps1 baixado esta vazio ou incompleto."
    }

    Write-Host "[+] Download concluido: $RunFileSize bytes." -ForegroundColor Green
    Write-Host "[+] Abrindo WinOptimizer..." -ForegroundColor Cyan

    Start-Sleep -Milliseconds 700

    & powershell.exe `
        -NoLogo `
        -NoProfile `
        -ExecutionPolicy Bypass `
        -File $RunFile

    $ProgramExitCode = $LASTEXITCODE

    if ($null -ne $ProgramExitCode -and $ProgramExitCode -ne 0) {
        Write-Host ""
        Write-Host "[!] WinOptimizer encerrou com codigo: $ProgramExitCode" -ForegroundColor Yellow
    }
}
catch {
    Write-Host ""
    Write-Host "[ERRO] Nao foi possivel iniciar o WinOptimizer." -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor DarkRed
    Write-Host ""
    Write-Host "Verifique sua conexao e confirme se run.ps1 existe na branch '$Branch'." -ForegroundColor Yellow
}
finally {
    Pause-WinOptimizer
}
