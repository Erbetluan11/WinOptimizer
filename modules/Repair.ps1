function Start-WindowsRepair {
    Show-Header
    Write-Host "REPARAR WINDOWS" -ForegroundColor Yellow
    Write-Host "Executa DISM RestoreHealth e SFC /scannow. O processo pode demorar."
    if (-not (Confirm-WinOptimizerAction "Deseja iniciar o reparo?")) { return }
    try {
        Write-Status "Executando DISM RestoreHealth. Aguarde..."
        Start-Process -FilePath "dism.exe" -ArgumentList "/Online", "/Cleanup-Image", "/RestoreHealth" -Wait -NoNewWindow
        Write-Status "Executando SFC /scannow. Aguarde..."
        Start-Process -FilePath "sfc.exe" -ArgumentList "/scannow" -Wait -NoNewWindow
        Write-Status "Processo de reparo finalizado." "Green"
        Save-AppliedChange "Manutencao" "Reparo do Windows" "DISM RestoreHealth e SFC /scannow executados."
    } catch { Write-Status "O reparo foi concluido parcialmente ou apresentou erro." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
