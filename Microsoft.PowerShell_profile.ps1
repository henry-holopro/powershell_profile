$profilePath = Split-Path -Path $PROFILE -Parent

$apps = ("JanDeDobbeleer.OhMyPosh", "GNU.nano")

foreach ($app in $apps) {
    $testapp = $($app -split "\." | Select-Object -Last 1)
    if (-not $(Start-Process $testapp -ArgumentList "--version")) {
        Write-Host "$testapp not found on system, installing."
        winget install $app -s winget
    }
}

oh-my-posh init pwsh --config "$profilePath/nordtron.omp.json" | Invoke-Expression

function Set-Commit {
    [CmdletBinding()]
    [Alias('commit')]
    param (
        [Parameter(Mandatory)]
        [String]
        $message
    )
    Read-Host -Prompt "Commit message: "
    git commit -a -m $message
}