function Start-TemporaryCleanup {
    Show-Header
    Write-Host "LIMPEZA DE ARQUIVOS TEMPORARIOS" -ForegroundColor Yellow
    Write-Host "Inclui temporarios, Lixeira e cache de download do Windows Update."
    if (-not (Confirm-WinOptimizerAction "Deseja iniciar a limpeza?")) { return }
    try {
        Write-Status "Limpando arquivos temporarios..."
        @("$env:TEMP\*", "$env:LOCALAPPDATA\Temp\*", "$env:WINDIR\Temp\*") | ForEach-Object { Remove-Item -Path $_ -Recurse -Force -ErrorAction SilentlyContinue }
        Write-Status "Limpando Lixeira..."; Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        Write-Status "Limpando cache de downloads do Windows Update..."
        Stop-Service -Name "wuauserv" -Force -ErrorAction SilentlyContinue; Stop-Service -Name "bits" -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "$env:WINDIR\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
        Start-Service -Name "bits" -ErrorAction SilentlyContinue; Start-Service -Name "wuauserv" -ErrorAction SilentlyContinue
        Write-Status "Limpeza concluida." "Green"
        Save-AppliedChange "Limpeza" "Arquivos temporarios" "Temporarios, Lixeira e cache do Windows Update limpos."
    } catch { Write-Status "A limpeza foi concluida parcialmente." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function Start-StorageOptimization {
    Show-Header
    Write-Host "OTIMIZAR ARMAZENAMENTO" -ForegroundColor Yellow
    Write-Host "Executa: DISM /Online /Cleanup-Image /StartComponentCleanup"
    if (-not (Confirm-WinOptimizerAction "Deseja iniciar a otimizacao de armazenamento?")) { return }
    try {
        Write-Status "Iniciando DISM StartComponentCleanup..."
        Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/StartComponentCleanup" -Wait -NoNewWindow
        Write-Status "Otimizacao de armazenamento concluida." "Green"
        Save-AppliedChange "Manutencao" "Limpeza de componentes" "DISM StartComponentCleanup executado."
    } catch { Write-Status "Nao foi possivel concluir a otimizacao." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
