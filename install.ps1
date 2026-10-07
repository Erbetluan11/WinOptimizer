# install.ps1 - WinOptimizer
# Uso: irm https://raw.githubusercontent.com/Erbetluan11/WinOptimizer/main/install.ps1 | iex

$repoOwner = "Erbetluan11"
$repoName  = "WinOptimizer"
$branch    = "main"

$runUrl = "https://raw.githubusercontent.com/$repoOwner/$repoName/$branch/run.ps1"

try {
    $script = Invoke-RestMethod -Uri $runUrl -ErrorAction Stop
    Invoke-Expression $script
} catch {
    Write-Host "Falha ao baixar run.ps1: $_" -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit 1
}
