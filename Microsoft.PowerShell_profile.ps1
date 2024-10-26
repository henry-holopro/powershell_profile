$profilePath = ""
$profilePath = Split-Path -Path $PROFILE -Parent

$apps = @{
    "oh-my-posh" = "JanDeDobbeleer.OhMyPosh"
    "nano" = "GNU.nano"
}

foreach ($app in $apps.Keys) {
    if (-not $(Get-Command $app -ErrorAction SilentlyContinue)) {
        Write-Host "$app not found on system, installing..."
        winget install $apps[$app] -s winget
    }
}

oh-my-posh init pwsh --config "$profilePath/nordtron.omp.json" | Invoke-Expression

function Set-Commit {
    [CmdletBinding()]
    [Alias('commit')]
    param (
        [Parameter(Position = 0)]
        [string]$message
    )
    
    if (-not $message) {
        $message = Read-Host -Prompt "Commit message"
    }

    git commit -a -m $message
}