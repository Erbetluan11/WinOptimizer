function Show-SystemDiagnostics {
    Show-Header
    Write-Host "DIAGNOSTICO COMPLETO DO SISTEMA" -ForegroundColor Yellow
    Write-Host ""
    try {
        $OS = Get-CimInstance Win32_OperatingSystem
        $Computer = Get-CimInstance Win32_ComputerSystem
        $BIOS = Get-CimInstance Win32_BIOS
        $CPU = Get-CimInstance Win32_Processor | Select-Object -First 1
        $GPUs = Get-CimInstance Win32_VideoController
        Write-Host "Computador : $($Computer.Manufacturer) $($Computer.Model)"
        Write-Host "Windows    : $($OS.Caption)"
        Write-Host "Versao     : $($OS.Version)"
        Write-Host "Build      : $($OS.BuildNumber)"
        Write-Host "BIOS       : $($BIOS.SMBIOSBIOSVersion)"
        Write-Host "CPU        : $($CPU.Name)"
        Write-Host "Nucleos    : $($CPU.NumberOfCores)"
        Write-Host "Threads    : $($CPU.NumberOfLogicalProcessors)"
        Write-Host "RAM        : $([math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)) GB"
        Write-Host "Uptime     : $([math]::Round(((Get-Date) - $OS.LastBootUpTime).TotalHours, 1)) horas"
        Write-Host ""; Write-Host "GPU:" -ForegroundColor Cyan
        foreach ($GPU in $GPUs) { Write-Host "- $($GPU.Name)" }
        Write-Host ""; Write-Host "Plano de energia:" -ForegroundColor Cyan
        powercfg /getactivescheme
        Write-Host ""; Write-Host "Armazenamento:" -ForegroundColor Cyan
        Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3" | ForEach-Object {
            $Free = [math]::Round($_.FreeSpace / 1GB, 2); $Size = [math]::Round($_.Size / 1GB, 2); $Used = [math]::Round($Size - $Free, 2); $Percent = [math]::Round(($Free / $_.Size) * 100, 0)
            Write-Host "$($_.DeviceID)  Usado: $Used GB | Livre: $Free GB / $Size GB ($Percent% livre)"
        }
        Write-Host ""; Write-Host "Inicializacao:" -ForegroundColor Cyan
        $Startup = Get-CimInstance Win32_StartupCommand
        if ($Startup) { $Startup | Select-Object Name, Command, Location | Format-Table -AutoSize } else { Write-Host "Nenhum item encontrado." }
        Write-Log "Diagnostico do sistema exibido."
    } catch { Write-Status "Nao foi possivel obter todas as informacoes." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
