$script:WinOptimizerRoot = $null
$script:WinOptimizerDataFolder = $null
$script:WinOptimizerBackupFolder = $null
$script:WinOptimizerLogFile = $null
$script:WinOptimizerChangesFile = $null
$script:WinOptimizerVersion = "2.0.0"

function Initialize-WinOptimizer {
    param([string]$RootPath, [string]$AppName, [string]$Version)
    $script:WinOptimizerRoot = $RootPath
    $script:WinOptimizerVersion = $Version
    $script:WinOptimizerDataFolder = Join-Path $env:ProgramData $AppName
    $script:WinOptimizerBackupFolder = Join-Path $script:WinOptimizerDataFolder "Backups"
    $script:WinOptimizerLogFile = Join-Path $script:WinOptimizerDataFolder "WinOptimizer.log"
    $script:WinOptimizerChangesFile = Join-Path $script:WinOptimizerDataFolder "changes.json"
    foreach ($Folder in @($script:WinOptimizerDataFolder, $script:WinOptimizerBackupFolder)) {
        if (-not (Test-Path $Folder)) { New-Item -Path $Folder -ItemType Directory -Force | Out-Null }
    }
    if (-not (Test-Path $script:WinOptimizerChangesFile)) { "[]" | Set-Content -Path $script:WinOptimizerChangesFile -Encoding UTF8 }
}
function Test-Administrator {
    $Identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $Principal = New-Object Security.Principal.WindowsPrincipal($Identity)
    return $Principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}
function Show-Header {
    Clear-Host
    Write-Host ""
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "                    WINOPTIMIZER v$script:WinOptimizerVersion" -ForegroundColor Cyan
    Write-Host "              Windows Maintenance, Tweaks and Tools" -ForegroundColor DarkCyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host ""
}
function Pause-WinOptimizer { Write-Host ""; Read-Host "Pressione Enter para continuar" }
function Confirm-WinOptimizerAction { param([string]$Message); Write-Host ""; return (Read-Host "$Message [S/N]") -match "^(S|SIM|Y|YES)$" }
function Write-Log { param([string]$Message, [string]$Level = "INFO"); Add-Content -Path $script:WinOptimizerLogFile -Value "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] [$Level] $Message" }
function Write-Status { param([string]$Message, [string]$Color = "Cyan"); Write-Host "[WinOptimizer] $Message" -ForegroundColor $Color; Write-Log -Message $Message }
function Save-AppliedChange {
    param([string]$Category, [string]$Name, [string]$Details)
    $Changes = @()
    $RawChanges = Get-Content -Path $script:WinOptimizerChangesFile -Raw
    if (-not [string]::IsNullOrWhiteSpace($RawChanges) -and $RawChanges -ne "[]") { $Changes = @($RawChanges | ConvertFrom-Json) }
    $Changes += [PSCustomObject]@{ Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"; Category = $Category; Name = $Name; Details = $Details }
    $Changes | ConvertTo-Json -Depth 5 | Set-Content -Path $script:WinOptimizerChangesFile -Encoding UTF8
}
function Show-WinOptimizerLog {
    Show-Header
    Write-Host "LOG DO WINOPTIMIZER" -ForegroundColor Yellow
    Write-Host "Arquivo: $script:WinOptimizerLogFile" -ForegroundColor DarkGray
    Write-Host ""
    if (Test-Path $script:WinOptimizerLogFile) { Get-Content -Path $script:WinOptimizerLogFile -Tail 100 } else { Write-Host "Nenhum log encontrado." }
    Pause-WinOptimizer
}
