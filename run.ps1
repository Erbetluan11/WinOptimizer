# =====================================================================
# WinOptimizer - Script principal
# Repositorio: https://github.com/Erbetluan11/WinOptimizer
# =====================================================================

$ErrorActionPreference = "SilentlyContinue"
$AppName = "WinOptimizer"
$Version = "1.1.0"
$Host.UI.RawUI.WindowTitle = "$AppName v$Version"

$WorkFolder = Join-Path $env:TEMP $AppName
$LogFile = Join-Path $WorkFolder "WinOptimizer.log"

if (-not (Test-Path $WorkFolder)) {
    New-Item -Path $WorkFolder -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Time = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$Time] [$Level] $Message"
}

function Write-Header {
    Clear-Host

    Write-Host ""
    Write-Host "  __        ___       ___        _   _           _" -ForegroundColor Cyan
    Write-Host "  \ \      / (_)_ __ / _ \ _ __ | |_(_)_ __ ___ (_)_______ _ __" -ForegroundColor Cyan
    Write-Host "   \ \ /\ / /| | '_ \ | | | '_ \| __| | '_ ' _ \| |_  / _ \ '__|" -ForegroundColor Cyan
    Write-Host "    \ V  V / | | | | | |_| | |_) | |_| | | | | | |/ /  __/ |" -ForegroundColor Cyan
    Write-Host "     \_/\_/ |_|_| |_|\___/| .__/ \__|_|_| |_| |_|_/___\___|_|" -ForegroundColor Cyan
    Write-Host "                           |_|" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "              Windows Cleanup, Repair and Tuning" -ForegroundColor DarkCyan
    Write-Host "              Version $Version" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor DarkCyan
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
        [ValidateSet("Cyan", "Green", "Yellow", "Red", "White", "DarkGray")]
        [string]$Color = "Cyan"
    )

    Write-Host "[WinOptimizer] $Message" -ForegroundColor $Color
    Write-Log -Message $Message
}

function New-RestorePoint {
    Write-Header

    Write-Host "Criar ponto de restauracao" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Cria um ponto de restauracao antes de configuracoes importantes."
    Write-Host "O Windows pode permitir apenas um novo ponto a cada 24 horas."
    Write-Host ""

    if (-not (Confirm-Action "Deseja criar o ponto de restauracao?")) {
        return
    }

    try {
        Write-Status "Tentando criar ponto de restauracao..."

        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue

        Checkpoint-Computer `
            -Description "WinOptimizer - $((Get-Date).ToString('yyyy-MM-dd HH-mm'))" `
            -RestorePointType "MODIFY_SETTINGS"

        Write-Status "Ponto de restauracao criado ou solicitado com sucesso." "Green"
    }
    catch {
        Write-Status "Nao foi possivel criar o ponto de restauracao." "Yellow"
        Write-Host ""
        Write-Host "Possiveis motivos:" -ForegroundColor Yellow
        Write-Host "- A Protecao do Sistema esta desativada."
        Write-Host "- Ja existe um ponto criado nas ultimas 24 horas."
        Write-Host "- O Windows bloqueou a operacao."
        Write-Log -Message $_.Exception.Message -Level "ERROR"
    }

    Pause-WinOptimizer
}

function Clear-TemporaryFiles {
    Write-Header

    Write-Host "Limpeza segura de arquivos temporarios" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Itens incluidos:"
    Write-Host "- Temporarios do usuario"
    Write-Host "- Temporarios do Windows"
    Write-Host "- Lixeira"
    Write-Host "- Cache de download do Windows Update"
    Write-Host ""
    Write-Host "Arquivos em uso serao ignorados."
    Write-Host ""

    if (-not (Confirm-Action "Deseja iniciar a limpeza?")) {
        return
    }

    $Locations = @(
        "$env:TEMP\*",
        "$env:LOCALAPPDATA\Temp\*",
        "$env:WINDIR\Temp\*"
    )

    Write-Status "Limpando arquivos temporarios..."

    foreach ($Location in $Locations) {
        Remove-Item -Path $Location -Recurse -Force -ErrorAction SilentlyContinue
    }

    try {
        Write-Status "Limpando Lixeira..."
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
    }
    catch {
        Write-Status "A Lixeira nao foi completamente limpa." "Yellow"
    }

    try {
        Write-Status "Limpando cache do Windows Update..."

        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue
        Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue

        Remove-Item `
            -Path "$env:WINDIR\SoftwareDistribution\Download\*" `
            -Recurse `
            -Force `
            -ErrorAction SilentlyContinue

        Start-Service -Name "bits" -ErrorAction SilentlyContinue
        Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
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
    Write-Host "Executa o DISM para remover componentes antigos substituidos."
    Write-Host "Pode liberar espaco em disco e pode demorar alguns minutos."
    Write-Host ""
    Write-Host "Comando: DISM /Online /Cleanup-Image /StartComponentCleanup"
    Write-Host ""

    if (-not (Confirm-Action "Deseja continuar com o DISM?")) {
        return
    }

    Write-Status "Iniciando limpeza de componentes. Aguarde..."

    Start-Process `
        -FilePath "dism.exe" `
        -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup" `
        -Wait `
        -NoNewWindow

    Write-Status "Limpeza de componentes finalizada." "Green"
    Pause-WinOptimizer
}

function Repair-Windows {
    Write-Header

    Write-Host "Verificar e reparar arquivos do Windows" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Etapas:"
    Write-Host "1. DISM /Online /Cleanup-Image /RestoreHealth"
    Write-Host "2. SFC /scannow"
    Write-Host ""
    Write-Host "O processo pode ser demorado. Nao feche a janela durante a execucao."
    Write-Host ""

    if (-not (Confirm-Action "Deseja iniciar o reparo?")) {
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

function Set-HighPerformancePlan {
    Write-Header

    Write-Host "Plano de energia: Alto desempenho" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Ativa o plano Alto desempenho padrao do Windows."
    Write-Host "Em notebooks, pode aumentar o consumo de bateria, calor e ruido."
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
        Write-Status "Nao foi possivel ativar esse plano neste computador." "Yellow"
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
    Write-Host "Mudancas que serao aplicadas:"
    Write-Host "- Reduzir telemetria por politica de sistema"
    Write-Host "- Desativar recursos de consumidor/recomendacoes"
    Write-Host "- Desativar identificador de publicidade"
    Write-Host ""
    Write-Host "Alguns recursos personalizados do Windows podem ser afetados."
    Write-Host ""

    if (-not (Confirm-Action "Deseja aplicar esses ajustes?")) {
        return
    }

    try {
        $DataCollection = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
        $CloudContent = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        $Advertising = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"

        New-Item -Path $DataCollection -Force | Out-Null
        New-Item -Path $CloudContent -Force | Out-Null
        New-Item -Path $Advertising -Force | Out-Null

        Set-ItemProperty -Path $DataCollection -Name "AllowTelemetry" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $CloudContent -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1 -Force
        Set-ItemProperty -Path $Advertising -Name "Enabled" -Type DWord -Value 0 -Force

        Write-Status "Ajustes de privacidade aplicados." "Green"
        Write-Host ""
        Write-Host "Reinicie o computador para aplicar todas as mudancas." -ForegroundColor Yellow
    }
    catch {
        Write-Status "Ocorreu um erro ao aplicar os ajustes." "Red"
        Write-Log -Message $_.Exception.Message -Level "ERROR"
    }

    Pause-WinOptimizer
}

function Reset-PrivacySettings {
    Write-Header

    Write-Host "Restaurar ajustes de privacidade" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Remove apenas as politicas gerenciadas por este WinOptimizer."
    Write-Host ""

    if (-not (Confirm-Action "Deseja restaurar os ajustes?")) {
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

        New-Item `
            -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
            -Force | Out-Null

        Set-ItemProperty `
            -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" `
            -Name "Enabled" `
            -Type DWord `
            -Value 1 `
            -Force

        Write-Status "Ajustes restaurados." "Green"
        Write-Host ""
        Write-Host "Reinicie o computador para aplicar completamente as mudancas." -ForegroundColor Yellow
    }
    catch {
        Write-Status "Nem todos os ajustes puderam ser restaurados." "Yellow"
        Write-Log -Message $_.Exception.Message -Level "ERROR"
    }

    Pause-WinOptimizer
}

function Show-SystemInformation {
    Write-Header

    Write-Host "Informacoes do sistema" -ForegroundColor Yellow
    Write-Host ""

    try {
        $OS = Get-CimInstance Win32_OperatingSystem
        $Computer = Get-CimInstance Win32_ComputerSystem
        $CPU = Get-CimInstance Win32_Processor | Select-Object -First 1
        $GPU = Get-CimInstance Win32_VideoController | Select-Object -First 1

        Write-Host "Computador : $($Computer.Manufacturer) $($Computer.Model)"
        Write-Host "Windows    : $($OS.Caption)"
        Write-Host "Build      : $($OS.BuildNumber)"
        Write-Host "CPU        : $($CPU.Name)"
        Write-Host "RAM        : $([math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)) GB"
        Write-Host "GPU        : $($GPU.Name)"
        Write-Host "Uptime     : $([math]::Round(((Get-Date) - $OS.LastBootUpTime).TotalHours, 1)) horas"
        Write-Host ""

        Write-Host "Armazenamento:" -ForegroundColor Cyan

        Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3" |
            ForEach-Object {
                $Free = [math]::Round($_.FreeSpace / 1GB, 2)
                $Size = [math]::Round($_.Size / 1GB, 2)
                $Percent = [math]::Round(($_.FreeSpace / $_.Size) * 100, 0)

                Write-Host "$($_.DeviceID)  Livre: $Free GB / $Size GB ($Percent% livre)"
            }
    }
    catch {
        Write-Status "Nao foi possivel coletar todas as informacoes." "Yellow"
        Write-Log -Message $_.Exception.Message -Level "ERROR"
    }

    Pause-WinOptimizer
}

function Show-Log {
    Write-Header

    Write-Host "Log do WinOptimizer" -ForegroundColor Yellow
    Write-Host "Arquivo: $LogFile" -ForegroundColor DarkGray
    Write-Host ""

    if (Test-Path $LogFile) {
        Get-Content -Path $LogFile -Tail 80
    }
    else {
        Write-Host "Nenhum log foi criado ainda."
    }

    Pause-WinOptimizer
}

function Show-Menu {
    Write-Header

    Write-Host "  MANUTENCAO" -ForegroundColor DarkCyan
    Write-Host "  [1] Criar ponto de restauracao"
    Write-Host "  [2] Limpar temporarios, Lixeira e cache do Update"
    Write-Host "  [3] Limpar componentes antigos do Windows (DISM)"
    Write-Host "  [4] Verificar e reparar Windows (DISM + SFC)"
    Write-Host ""
    Write-Host "  DESEMPENHO" -ForegroundColor DarkCyan
    Write-Host "  [5] Ativar plano Alto desempenho"
    Write-Host "  [6] Ver plano de energia atual"
    Write-Host ""
    Write-Host "  PRIVACIDADE" -ForegroundColor DarkCyan
    Write-Host "  [7] Aplicar ajustes basicos de privacidade"
    Write-Host "  [8] Restaurar ajustes de privacidade"
    Write-Host ""
    Write-Host "  SISTEMA" -ForegroundColor DarkCyan
    Write-Host "  [9] Ver informacoes do computador"
    Write-Host "  [L] Ver log do WinOptimizer"
    Write-Host ""
    Write-Host "  [0] Sair" -ForegroundColor Red
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor DarkCyan
    Write-Host ""
}

# Inicio do programa
if (-not (Test-Administrator)) {
    Clear-Host
    Write-Host ""
    Write-Host "Este programa precisa ser executado como Administrador." -ForegroundColor Red
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Log -Message "WinOptimizer v$Version iniciado."

do {
    Show-Menu
    $Option = (Read-Host "Escolha uma opcao").ToUpper()

    switch ($Option) {
        "1" { New-RestorePoint }
        "2" { Clear-TemporaryFiles }
        "3" { Start-ComponentCleanup }
        "4" { Repair-Windows }
        "5" { Set-HighPerformancePlan }
        "6" { Show-ActivePowerPlan }
        "7" { Apply-PrivacySettings }
        "8" { Reset-PrivacySettings }
        "9" { Show-SystemInformation }
        "L" { Show-Log }
        "0" { break }

        default {
            Write-Host ""
            Write-Host "Opcao invalida. Escolha uma opcao exibida no menu." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
}
while ($Option -ne "0")

Write-Log -Message "WinOptimizer finalizado."

Clear-Host
Write-Host ""
Write-Host "Obrigado por usar o WinOptimizer." -ForegroundColor Cyan
Start-Sleep -Seconds 1
