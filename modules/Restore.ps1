function Set-PrivacyTweaks {
    Show-Header
    Write-Host "AJUSTES BASICOS DE PRIVACIDADE" -ForegroundColor Yellow
    Write-Host "- Reduzir telemetria por politica`n- Desativar recursos de consumidor/recomendacoes`n- Desativar identificador de publicidade"
    if (-not (Confirm-WinOptimizerAction "Deseja aplicar os ajustes de privacidade?")) { return }
    try {
        $DataCollection = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"; $CloudContent = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"; $Advertising = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
        New-Item -Path $DataCollection -Force | Out-Null; New-Item -Path $CloudContent -Force | Out-Null; New-Item -Path $Advertising -Force | Out-Null
        Set-ItemProperty -Path $DataCollection -Name "AllowTelemetry" -Type DWord -Value 0 -Force
        Set-ItemProperty -Path $CloudContent -Name "DisableWindowsConsumerFeatures" -Type DWord -Value 1 -Force
        Set-ItemProperty -Path $Advertising -Name "Enabled" -Type DWord -Value 0 -Force
        Write-Status "Ajustes de privacidade aplicados. Reinicie o computador." "Green"
        Save-AppliedChange "Privacidade" "Ajustes basicos" "Telemetria, recursos de consumidor e identificador de publicidade ajustados."
    } catch { Write-Status "Nao foi possivel aplicar todos os ajustes." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function Reset-PrivacyTweaks {
    Show-Header
    Write-Host "RESTAURAR AJUSTES DE PRIVACIDADE" -ForegroundColor Yellow
    Write-Host "Remove apenas politicas aplicadas por este WinOptimizer."
    if (-not (Confirm-WinOptimizerAction "Deseja restaurar os ajustes de privacidade?")) { return }
    try {
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -ErrorAction SilentlyContinue
        New-Item -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Force | Out-Null
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Type DWord -Value 1 -Force
        Write-Status "Ajustes de privacidade restaurados. Reinicie o computador." "Green"
        Save-AppliedChange "Privacidade" "Ajustes restaurados" "Politicas de privacidade do WinOptimizer removidas."
    } catch { Write-Status "Nao foi possivel restaurar todos os ajustes." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
