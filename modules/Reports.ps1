function Show-AppliedChanges {
    Show-Header
    Write-Host "ALTERACOES APLICADAS" -ForegroundColor Yellow
    try {
        $Raw = Get-Content -Path $script:WinOptimizerChangesFile -Raw
        if ([string]::IsNullOrWhiteSpace($Raw) -or $Raw -eq "[]") { Write-Host "Nenhuma alteracao foi registrada ainda." } else { @($Raw | ConvertFrom-Json) | Sort-Object Date -Descending | Format-Table Date, Category, Name, Details -AutoSize }
    } catch { Write-Status "Nao foi possivel ler o historico de alteracoes." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
function New-HtmlReport {
    Show-Header
    Write-Host "GERAR RELATORIO HTML" -ForegroundColor Yellow
    try {
        $Date = Get-Date -Format "yyyyMMdd-HHmmss"; $ReportFile = Join-Path $script:WinOptimizerDataFolder "Relatorio-$Date.html"
        $OS = Get-CimInstance Win32_OperatingSystem; $Computer = Get-CimInstance Win32_ComputerSystem; $CPU = Get-CimInstance Win32_Processor | Select-Object -First 1; $GPU = Get-CimInstance Win32_VideoController | Select-Object -First 1; $Drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType = 3"
        $Raw = Get-Content -Path $script:WinOptimizerChangesFile -Raw
        $ChangesHtml = if (-not [string]::IsNullOrWhiteSpace($Raw) -and $Raw -ne "[]") { @($Raw | ConvertFrom-Json) | Sort-Object Date -Descending | ConvertTo-Html -Fragment -Property Date, Category, Name, Details | Out-String } else { "<p>Nenhuma alteracao registrada.</p>" }
        $DrivesHtml = $Drives | ForEach-Object { [PSCustomObject]@{ Unidade = $_.DeviceID; TotalGB = [math]::Round($_.Size / 1GB, 2); LivreGB = [math]::Round($_.FreeSpace / 1GB, 2); LivrePercentual = "$([math]::Round(($_.FreeSpace / $_.Size) * 100, 0))%" } } | ConvertTo-Html -Fragment | Out-String
        $Html = @"
<!DOCTYPE html><html lang="pt-BR"><head><meta charset="UTF-8"><title>Relatorio WinOptimizer</title><style>body{background:#07111f;color:#eaf6ff;font-family:Segoe UI,Arial,sans-serif;margin:40px}h1,h2{color:#59dcff}.card{background:#10233b;border:1px solid #204568;padding:20px;border-radius:14px;margin:18px 0}table{width:100%;border-collapse:collapse;margin-top:12px}th,td{border:1px solid #294d70;padding:10px;text-align:left}th{background:#173a5b;color:#bdefff}tr:nth-child(even){background:#0b1b2e}small{color:#9db2c7}</style></head><body><h1>WinOptimizer - Relatorio do Sistema</h1><small>Gerado em: $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")</small><div class="card"><h2>Sistema</h2><p><strong>Computador:</strong> $($Computer.Manufacturer) $($Computer.Model)</p><p><strong>Windows:</strong> $($OS.Caption)</p><p><strong>Build:</strong> $($OS.BuildNumber)</p><p><strong>CPU:</strong> $($CPU.Name)</p><p><strong>RAM:</strong> $([math]::Round($Computer.TotalPhysicalMemory / 1GB, 2)) GB</p><p><strong>GPU:</strong> $($GPU.Name)</p></div><div class="card"><h2>Armazenamento</h2>$DrivesHtml</div><div class="card"><h2>Alteracoes registradas</h2>$ChangesHtml</div></body></html>
"@
        $Html | Set-Content -Path $ReportFile -Encoding UTF8
        Write-Status "Relatorio criado em: $ReportFile" "Green"; Start-Process $ReportFile; Save-AppliedChange "Relatorio" "Relatorio HTML" $ReportFile
    } catch { Write-Status "Nao foi possivel gerar o relatorio HTML." "Yellow"; Write-Log $_.Exception.Message "ERROR" }
    Pause-WinOptimizer
}
