function Show-NetworkDiagnostics {
    Show-Header
    Write-Host "DIAGNOSTICO DE REDE" -ForegroundColor Yellow
    try {
        Write-Host "Adaptadores ativos:" -ForegroundColor Cyan
        Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object Name, InterfaceDescription, LinkSpeed, MacAddress | Format-Table -AutoSize
        Write-Host "Configuracao IP:" -ForegroundColor Cyan
        Get-NetIPConfiguration | Where-Object { $_.IPv4Address } | Format-List InterfaceAlias, IPv4Address, IPv4DefaultGateway, DNSServer
        Write-Host "Teste de conectividade (1.1.1.1):" -ForegroundColor Cyan
        Test-Connection -ComputerName "1.1.1.1" -Count 4 | Select-Object Address, ResponseTime, Status | Format-Table -AutoSize
        Write-Host "Teste de DNS (cloudflare.com):" -ForegroundColor Cyan
        Resolve-DnsName "cloudflare.com" | Select-Object Name, Type, IPAddress | Format-Table -AutoSize
        Write-Log "Diagnostico de rede exibido."
    } catch { Write-Status "Nao foi possivel concluir todos os testes de rede." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function Clear-DnsCache {
    Show-Header; Write-Host "LIMPAR CACHE DNS" -ForegroundColor Yellow
    if (-not (Confirm-WinOptimizerAction "Deseja limpar o cache DNS?")) { return }
    try { Clear-DnsClientCache; ipconfig /flushdns | Out-Null; Write-Status "Cache DNS limpo." "Green"; Save-AppliedChange "Rede" "Cache DNS" "Cache DNS limpo." } catch { Write-Status "Nao foi possivel limpar o cache DNS." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function Set-PreferredDns {
    Show-Header
    Write-Host "ALTERAR DNS" -ForegroundColor Yellow
    Write-Host "[1] Cloudflare - 1.1.1.1 e 1.0.0.1"; Write-Host "[2] Google - 8.8.8.8 e 8.8.4.4"; Write-Host "[3] Automatico"
    $Choice = Read-Host "Escolha uma opcao"
    $Adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" -and $_.HardwareInterface }
    if (-not $Adapters) { Write-Status "Nenhum adaptador de rede ativo foi encontrado." "Yellow"; Pause-WinOptimizer; return }
    switch ($Choice) { "1" { $DnsServers = @("1.1.1.1", "1.0.0.1"); $Name = "Cloudflare" } "2" { $DnsServers = @("8.8.8.8", "8.8.4.4"); $Name = "Google" } "3" { $DnsServers = $null; $Name = "Automatico" } default { Write-Host "Opcao invalida." -ForegroundColor Red; Pause-WinOptimizer; return } }
    foreach ($Adapter in $Adapters) { Write-Host "- $($Adapter.Name)" }
    if (-not (Confirm-WinOptimizerAction "Deseja aplicar DNS $Name nesses adaptadores?")) { return }
    try {
        foreach ($Adapter in $Adapters) { if ($null -eq $DnsServers) { Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ResetServerAddresses } else { Set-DnsClientServerAddress -InterfaceIndex $Adapter.ifIndex -ServerAddresses $DnsServers } }
        Write-Status "DNS configurado: $Name." "Green"; Save-AppliedChange "Rede" "DNS" "DNS configurado como $Name."
    } catch { Write-Status "Nao foi possivel alterar o DNS." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function Reset-NetworkConfiguration {
    Show-Header
    Write-Host "RESTAURAR CONFIGURACOES DE REDE" -ForegroundColor Yellow
    Write-Host "Executa winsock reset, IP reset e flush DNS. Reinicie ao final."
    if (-not (Confirm-WinOptimizerAction "Deseja restaurar a configuracao de rede?")) { return }
    try { netsh winsock reset | Out-Host; netsh int ip reset | Out-Host; ipconfig /flushdns | Out-Host; Write-Status "Configuracoes de rede restauradas. Reinicie o computador." "Green"; Save-AppliedChange "Rede" "Reset de rede" "Winsock, IP e cache DNS redefinidos." } catch { Write-Status "Nao foi possivel concluir a restauracao de rede." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
