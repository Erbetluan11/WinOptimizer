function New-WinOptimizerRestorePoint {
    Show-Header
    Write-Host "CRIAR PONTO DE RESTAURACAO" -ForegroundColor Yellow
    Write-Host "O Windows pode limitar a criacao a um ponto por 24 horas."
    if (-not (Confirm-WinOptimizerAction "Deseja criar um ponto de restauracao?")) { return }
    try {
        Enable-ComputerRestore -Drive "$env:SystemDrive\" -ErrorAction SilentlyContinue
        Checkpoint-Computer -Description "WinOptimizer - $((Get-Date).ToString('yyyy-MM-dd HH-mm'))" -RestorePointType "MODIFY_SETTINGS"
        Write-Status "Ponto de restauracao criado ou solicitado." "Green"
        Save-AppliedChange "Backup" "Ponto de restauracao" "Criado em $((Get-Date).ToString('yyyy-MM-dd HH:mm:ss'))"
    } catch { Write-Status "Nao foi possivel criar o ponto de restauracao." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function New-WinOptimizerBackup {
    Show-Header
    Write-Host "BACKUP DAS CONFIGURACOES" -ForegroundColor Yellow
    Write-Host "Serao exportadas chaves de Registro usadas pelos ajustes de privacidade."
    if (-not (Confirm-WinOptimizerAction "Deseja criar o backup?")) { return }
    $Date = Get-Date -Format "yyyyMMdd-HHmmss"; $BackupFolder = Join-Path $script:WinOptimizerBackupFolder "Backup-$Date"
    New-Item -Path $BackupFolder -ItemType Directory -Force | Out-Null
    try {
        reg.exe export "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" (Join-Path $BackupFolder "DataCollection.reg") /y | Out-Null
        reg.exe export "HKLM\SOFTWARE\Policies\Microsoft\Windows\CloudContent" (Join-Path $BackupFolder "CloudContent.reg") /y | Out-Null
        reg.exe export "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" (Join-Path $BackupFolder "AdvertisingInfo.reg") /y | Out-Null
        [PSCustomObject]@{ CreatedAt = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Computer = $env:COMPUTERNAME; User = $env:USERNAME; BackupFolder = $BackupFolder } | ConvertTo-Json | Set-Content -Path (Join-Path $BackupFolder "backup-info.json") -Encoding UTF8
        Write-Status "Backup criado em: $BackupFolder" "Green"
        Save-AppliedChange "Backup" "Backup de Registro" $BackupFolder
    } catch { Write-Status "O backup foi criado parcialmente ou ocorreu um erro." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
