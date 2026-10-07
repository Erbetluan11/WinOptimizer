# ============================================================
# WinOptimizer - Script principal
# Repositorio: https://github.com/Erbetluan11/WinOptimizer
# Execute pelo install.ps1 ou como Administrador
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "WinOptimizer"

function Write-Header {
    Clear-Host

    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host "                     WinOptimizer" -ForegroundColor Cyan
    Write-Host "          Otimizacao, limpeza e manutencao do Windows" -ForegroundColor DarkCyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-WinOptimizer {
    Write-Host ""
    Read-Host "Pressione Enter para continuar"
}

function Test-Administrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)

    return $Principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Confirm-Action {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Message
    )

    Write-Host ""
    $Answer = Read-Host "$Message [S/N]"

    return $Answer -match "^(S|SIM|Y|YES)$"
}

function Write-Status {
    param(
        [string]$Message,
        [string]$Color = "Cyan"
    )

    Write-Host "[WinOptimizer] $Message" -ForegroundColor $Color
}

function New-RestorePoint {
    Write-Header

    Write-Host "Criar ponto de restauracao" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Isso cria uma protecao antes de alterar configuracoes do Windows."
    Write-Host "O Windows pode limitar a criacao a um ponto por dia."
    Write-Host ""

    if (-not (Confirm-Action "Deseja continuar?")) {
        return
    }

    try {
        Write-Status "Criando ponto de restauracao..."

        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue

        Checkpoint-Computer `
            -Description "WinOptimizer - Antes das otimizações" `
            -RestorePointType "MODIFY_SETTINGS"

        Write-Status "Ponto de restauracao criado com sucesso." "Green"
    }
    catch {
        Write-Status "Nao foi possivel criar o ponto de restauracao." "Yellow"
        Write-Host "Possiveis motivos:" -ForegroundColor Yellow
        Write-Host "- A Protecao do Sistema esta desativada."
        Write-Host "- Ja foi criado um ponto nas ultimas 24 horas."
        Write-Host "- O Windows bloqueou a operacao."
    }

    Pause-WinOptimizer
}

function Clear-TemporaryFiles {
    Write-Header

    Write-Host "Limpeza de arquivos temporarios" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esta opcao tenta limpar:"
    Write-Host "- Arquivos temporarios do usuario"
    Write-Host "- Arquivos temporarios do Windows"
    Write-Host "- Lixeira"
    Write-Host "- Cache basico do Windows Update"
    Write-Host ""

    if (-not (Confirm-Action "Deseja iniciar a limpeza?")) {
        return
    }

    $Locations = @(
        "$env:TEMP\*",
        "$env:WINDIR\Temp\*"
    )

    Write-Status "Limpando arquivos temporarios..."

    foreach ($Location in $Locations) {
        Remove-Item -Path $Location -Recurse -Force -ErrorAction SilentlyContinue
    }

    Write-Status "Limpando a Lixeira..."

    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Status "Nao foi possivel limpar completamente a Lixeira." "Yellow"
    }

    Write-Status "Limpando cache do Windows Update..."

    try {
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "$env:WINDIR\SoftwareDistribution\Download\*" `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue

        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Start-Service -Name "bits" -ErrorAction SilentlyContinue
    }
    catch {
        Write-Status "Parte do cache do Windows Update nao foi removida." "Yellow"
    }

    Write-Status "Limpeza concluida." "Green"
    Pause-WinOptimizer
}

function Start-ComponentCleanup {
    Write-Header

    Write-Host "Limpeza de componentes do Windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Executa: DISM /Online /Cleanup-Image /StartComponentCleanup"
    Write-Host ""
    Write-Host "Isso remove componentes substituidos por atualizacoes do Windows."
    Write-Host "Pode liberar espaco, mas pode demorar alguns minutos."
    Write-Host ""

    if (-not (Confirm-Action "Deseja executar a limpeza de componentes?")) {
        return
    }

    Write-Status "Executando DISM. Aguarde..."

    Start-Process `
        -FilePath "dism.exe" `
        -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup" `
        -Wait `
        -NoNewWindow

    Write-Status "Processo do DISM finalizado." "Green"
    Pause-WinOptimizer
}

function Repair-Windows {
    Write-Header

    Write-Host "Reparar arquivos do Windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esta opcao executa, nesta ordem:"
    Write-Host "1. DISM /Online /Cleanup-Image /RestoreHealth"
    Write-Host "2. sfc /scannow"
    Write-Host ""
    Write-Host "Pode demorar bastante e requer conexao com a internet em alguns casos."
    Write-Host ""

    if (-not (Confirm-Action "Deseja iniciar a verificacao e reparo?")) {
        return
    }

    Write-Status "Executando DISM RestoreHealth. Aguarde..."

    Start-Process `
        -FilePath "dism.exe" `
        -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" `
        -Wait `
        -NoNewWindow

    Write-Status "Executando SFC /scannow. Aguarde..."

    Start-Process `
        -FilePath "sfc.exe" `
        -ArgumentList "/scannow" `
        -Wait `
        -NoNewWindow

    Write-Status "Verificacao e reparo finalizados." "Green"
    Pause-WinOptimizer
}

function Set-PerformancePowerPlan {
    Write-Header

    Write-Host "Plano de energia: Alto desempenho" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ativa o plano padrao Alto desempenho do Windows."
    Write-Host "Em notebooks, isso pode aumentar consumo, calor e uso da bateria."
    Write-Host ""

    if (-not (Confirm-Action "Deseja ativar Alto desempenho?")) {
        return
    }

    $HighPerformanceGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"

    Write-Status "Ativando plano Alto desempenho..."

    powercfg /setactive $HighPerformanceGuid

    if ($LASTEXITCODE -eq 0) {
        Write-Status "Plano Alto desempenho ativado." "Green"
    }
    else {
        Write-Status "O plano Alto desempenho nao esta disponivel neste computador." "Yellow"
        Write-Host "Tente executar: powercfg /list"
    }

    Pause-WinOptimizer
}

function Show-ActivePowerPlan {
    Write-Header

    Write-Host "Plano de energia atual" -ForegroundColor Yellow
    Write-Host ""

    powercfg /getactivescheme

    Pause-WinOptimizer
}

function Apply-PrivacySettings {
    Write-Header

    Write-Host "Ajustes basicos de privacidade" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esta opcao aplica politicas para reduzir telemetria opcional."
    Write-Host "Alguns recursos e recomendacoes personalizadas do Windows podem ser afetados."
    Write-Host ""

    if (-not (Confirm-Action "Deseja aplicar os ajustes de privacidade?")) {
        return
    }

    try {
        $DataCollection = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        $CloudContent = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        $Advertising = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"

        New-Item -Path $DataCollection -Force | Out-Null
        New-Item -Path $CloudContent -Force | Out-Null
        New-Item -Path $Advertising -Force | Out-Null

        Set-ItemProperty `
            -Path $DataCollection `
            -Name "AllowTelemetry" `
            -Type DWord `
            -Value 0 `
            -Force

        Set-ItemProperty `
            -Path $CloudContent `
            -Name "DisableWindowsConsumerFeatures" `
            -Type DWord `
            -Value 1 `
            -Force

        Set-ItemProperty `
            -Path $Advertising `
            -Name "Enabled" `
            -Type DWord `
            -Value 0 `
            -Force

        Write-Status "Ajustes de privacidade aplicados." "Green"
        Write-Host "Reinicie o computador para garantir que todas as mudancas sejam aplicadas." -ForegroundColor Yellow
    }
    catch {
        Write-Status "Ocorreu um erro ao aplicar os ajustes." "Red"
    }

    Pause-WinOptimizer
}

function Reset-PrivacySettings {
    Write-Header

    Write-Host "Restaurar ajustes de privacidade" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esta opcao remove somente as politicas aplicadas pelo WinOptimizer."
    Write-Host ""

    if (-not (Confirm-Action "Deseja restaurar esses ajustes?")) {
        return
    }

    try {
        Remove-ItemProperty `
            -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" `
            -Name "AllowTelemetry" `
            -ErrorAction SilentlyContinue

        Remove-ItemProperty `
            -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" `
            -Name "DisableWindowsConsumerFeatures" `
            -ErrorAction SilentlyContinue

        Set-ItemProperty `
            -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
            -Name "Enabled" `
            -Type DWord `
            -Value 1 `
            -Force

        Write-Status "Ajustes restaurados." "Green"
        Write-Host "Reinicie o computador para aplicar completamente as mudancas." -ForegroundColor Yellow
    }
    catch {
        Write-Status "Nao foi possivel restaurar todos os ajustes." "Yellow"
    }

    Pause-WinOptimizer
}

function Show-SystemInformation {
    Write-Header

    Write-Host "Informacoes do sistema" -ForegroundColor Yellow
    Write-Host ""

    $OS = Get-CimInstance Win32_OperatingSystem
    $Computer = Get-CimInstance Win32_ComputerSystem
    $CPU = Get-CimInstance Win32_Processor | Select-Object -First 1
    $GPU = Get-CimInstance Win32_VideoController | Select-Object -First 1

    Write-Host "Computador: $($Computer.Manufacturer) $($Computer.Model)"
    Write-Host "Windows: $($OS.Caption) - Build $($OS.BuildNumber)"
    Write-Host "Processador: $($CPU.Name)"
    Write-Host "Memoria RAM: $([math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)) GB"
    Write-Host "GPU: $($GPU.Name)"
    Write-Host "Inicializacao: $($OS.LastBootUpTime)"
    Write-Host ""

    Write-Host "Discos:" -ForegroundColor Cyan

    Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3" |
        ForEach-Object {
            $Free = [math]::Round($_.FreeSpace / 1GB, 2)
            $Size = [math]::Round($_.Size / 1GB, 2)

            Write-Host "$($_.DeviceID) - Livre: $Free GB de $Size GB"
        }

    Pause-WinOptimizer
}

function Show-Menu {
    Write-Header

    Write-Host "[1] Criar ponto de restauracao" -ForegroundColor White
    Write-Host "[2] Limpar arquivos temporarios e Lixeira" -ForegroundColor White
    Write-Host "[3] Limpar componentes antigos do Windows (DISM)" -ForegroundColor White
    Write-Host "[4] Verificar e reparar arquivos do Windows (DISM + SFC)" -ForegroundColor White
    Write-Host "[5] Ativar plano Alto desempenho" -ForegroundColor White
    Write-Host "[6] Ver plano de energia atual" -ForegroundColor White
    Write-Host "[7] Aplicar ajustes basicos de privacidade" -ForegroundColor White
    Write-Host "[8] Restaurar ajustes de privacidade" -ForegroundColor White
    Write-Host "[9] Ver informacoes do sistema" -ForegroundColor White
    Write-Host "[0] Sair" -ForegroundColor Red
    Write-Host ""
}

# ------------------------------------------------------------
# Inicio do programa
# ------------------------------------------------------------

if (-not (Test-Administrator)) {
    Clear-Host
    Write-Host ""
    Write-Host "Este programa precisa ser executado como Administrador." -ForegroundColor Red
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

do {
    Show-Menu
    $Option = Read-Host "Escolha uma opcao"

    switch ($Option) {
        "1" { New-RestorePoint }
        "2" { Clear-TemporaryFiles }
        "3" { Start-ComponentCleanup }
        "4" { Repair-Windows }
        "5" { Set-PerformancePowerPlan }
        "6" { Show-ActivePowerPlan }
        "7" { Apply-PrivacySettings }
        "8" { Reset-PrivacySettings }
        "9" { Show-SystemInformation }
        "0" { break }
        default {
            Write-Host ""
            Write-Host "Opcao invalida." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
while ($Option -ne "0")

Clear-Host
Write-Host ""
Write-Host "Obrigado por usar o WinOptimizer." -ForegroundColor Cyan
Start-Sleep -Seconds 1
