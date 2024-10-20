if (-not $(oh-my-posh --version)) {
    Write-Host "Oh My Posh not found on system, installing."
    winget install JanDeDobbeleer.OhMyPosh -s winget
}
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/jandedobbeleer.omp.json" | Invoke-Expression