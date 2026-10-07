$ErrorActionPreference = "SilentlyContinue"
$AppName="WinOptimizer"; $Version="2.1.0"; $RootPath=$PSScriptRoot
$Host.UI.RawUI.WindowTitle="$AppName v$Version - Debloat Edition"
$modules=@("modules\Core.ps1","modules\Diagnostics.ps1","modules\Backup.ps1","modules\Profiles.ps1","modules\Cleanup.ps1","modules\Repair.ps1","modules\Network.ps1","modules\Reports.ps1","modules\Restore.ps1","modules\Debloat.ps1","modules\Services.ps1","modules\Apps.ps1")
foreach($module in $modules){$path=Join-Path $RootPath $module;if(-not(Test-Path $path)){Write-Host "Modulo ausente: $module" -ForegroundColor Red;Read-Host "Pressione Enter";exit 1};. $path}
Initialize-WinOptimizer -RootPath $RootPath -AppName $AppName -Version $Version
if(-not(Test-Administrator)){Write-Host "Execute como Administrador." -ForegroundColor Red;Read-Host "Pressione Enter";exit 1}
Write-Log "WinOptimizer v$Version iniciado."
do {
 Show-Header
 Write-Host " [1] Diagnostico completo do sistema"
 Write-Host " [2] Criar ponto de restauracao"
 Write-Host " [3] Fazer backup das configuracoes"
 Write-Host " [4] Aplicar perfil para jogos"
 Write-Host " [5] Aplicar perfil equilibrado"
 Write-Host " [6] Aplicar perfil para notebook"
 Write-Host "";Write-Host " ------------------------ MANUTENCAO -------------------------------" -ForegroundColor DarkCyan
 Write-Host " [7] Otimizar armazenamento (DISM)"
 Write-Host " [8] Limpar arquivos temporarios"
 Write-Host " [9] Reparar Windows (DISM + SFC)"
 Write-Host "";Write-Host " ------------------------- REDE ------------------------------------" -ForegroundColor DarkCyan
 Write-Host " [10] Diagnosticar rede";Write-Host " [11] Limpar cache DNS";Write-Host " [12] Alterar DNS";Write-Host " [13] Restaurar configuracoes de rede"
 Write-Host "";Write-Host " ------------------- DEBLOAT E PRIVACIDADE -------------------------" -ForegroundColor DarkCyan
 Write-Host " [14] Menu de Debloat (Seguro / Performance / Agressivo)"
 Write-Host " [15] Gerenciar apps UWP individualmente"
 Write-Host " [16] Gerenciar servicos opcionais"
 Write-Host " [17] Aplicar ajustes basicos de privacidade"
 Write-Host " [18] Restaurar ajustes de privacidade"
 Write-Host "";Write-Host " ------------------- RELATORIOS E RESTAURACAO ----------------------" -ForegroundColor DarkCyan
 Write-Host " [19] Ver alteracoes aplicadas";Write-Host " [20] Gerar relatorio HTML";Write-Host " [L] Ver log";Write-Host " [0] Sair" -ForegroundColor Red
 $option=(Read-Host "Escolha uma opcao").ToUpper()
 switch($option){
  "1"{Show-SystemDiagnostics};"2"{New-WinOptimizerRestorePoint};"3"{New-WinOptimizerBackup};"4"{Set-WinOptimizerProfile -Profile Gaming};"5"{Set-WinOptimizerProfile -Profile Balanced};"6"{Set-WinOptimizerProfile -Profile Laptop};"7"{Start-StorageOptimization};"8"{Start-TemporaryCleanup};"9"{Start-WindowsRepair};"10"{Show-NetworkDiagnostics};"11"{Clear-DnsCache};"12"{Set-PreferredDns};"13"{Reset-NetworkConfiguration};"14"{Show-DebloatMenu};"15"{Show-AppManager};"16"{Show-ServiceManager};"17"{Set-PrivacyTweaks};"18"{Reset-PrivacyTweaks};"19"{Show-AppliedChanges};"20"{New-HtmlReport};"L"{Show-WinOptimizerLog};"0"{break};default{Write-Host "Opcao invalida." -ForegroundColor Red;Start-Sleep 1}
 }
}while($option -ne "0")
Write-Log "WinOptimizer finalizado.";Clear-Host;Write-Host "Obrigado por usar o WinOptimizer." -ForegroundColor Cyan
