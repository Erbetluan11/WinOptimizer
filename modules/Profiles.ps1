function Set-WinOptimizerProfile {
    param([ValidateSet("Gaming", "Balanced", "Laptop")][string]$Profile)
    Show-Header
    Write-Host "PERFIL: $Profile" -ForegroundColor Yellow
    Write-Host ""
    switch ($Profile) {
        "Gaming" { Write-Host "- Plano Alto desempenho`n- Limpeza opcional de temporarios`n- Nao desativa Defender, Update ou servicos criticos" }
        "Balanced" { Write-Host "- Plano Equilibrado`n- Limpeza opcional de temporarios`n- Sem mudancas em servicos criticos" }
        "Laptop" { Write-Host "- Plano Equilibrado`n- Limpeza opcional de temporarios`n- Configuracao conservadora para bateria" }
    }
    if (-not (Confirm-WinOptimizerAction "Deseja aplicar esse perfil?")) { return }
    try {
        $Guid = if ($Profile -eq "Gaming") { "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c" } else { "381b4222-f694-41f0-9685-ff5bb260df2e" }
        powercfg /setactive $Guid
        Write-Status "Plano de energia configurado para $Profile." "Green"
        Save-AppliedChange "Perfil" "Perfil $Profile" "Plano de energia configurado."
        if (Confirm-WinOptimizerAction "Executar limpeza de temporarios agora?") { Start-TemporaryCleanup }
    } catch { Write-Status "Ocorreu um erro ao aplicar o perfil." "Red"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
