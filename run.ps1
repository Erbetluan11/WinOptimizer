# run.ps1 - WinOptimizer
# Executar como Administrador

if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Execute o PowerShell como Administrador." -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Host "================================" -ForegroundColor Cyan
Write-Host "       WinOptimizer - Inicio   " -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan

# --- COLOQUE AQUI SEUS COMANDOS DE OTIMIZACAO ---
# Exemplos (descomente e adapte):
# .\scripts\debloat.ps1
# .\scripts\optimize-system.ps1
# .\scripts\privacy.ps1

# Exemplo simples: desativar telemetria básica (apenas exemplo)
# Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Force

Write-Host "Otimizacao concluida." -ForegroundColor Green
Read-Host "Pressione Enter para sair"
