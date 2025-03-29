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

function Set-Push {
    [Cmdletbinding()]
    [Alias('push')]
    param()
     
    git push
}

function Set-Add {
    [Cmdletbinding()]
    [Alias('add')]
    param(
        [Parameter(Position = 0)]
        [string]$add     
    )
    git add $add
}
#f45873b3-b655-43a6-b217-97c00aa0db58 PowerToys CommandNotFound module

Import-Module -Name Microsoft.WinGet.CommandNotFound
#f45873b3-b655-43a6-b217-97c00aa0db58

function Start-BWCli {
    [Cmdletbinding()]
    [Alias('bwcli')]
    param()
    
    # Execute the login command and capture its output
    try {
        $loginCommand = "bw unlock"
        $bw_login = Invoke-Expression $loginCommand -ErrorAction Stop
    }
    catch {
        Write-Output "Error: $($_.Exception.Message)"
        Exit 1
    }
    # Extract the session key command using regex
    $commandPattern = '>\s*(\$env:BW_SESSION="[^"]+")' 
    $commandMatch = [regex]::Match($bw_login, $commandPattern)

    if ($commandMatch.Success) {
        $fullCommand = $commandMatch.Groups[1].Value
        Invoke-Expression $fullCommand
        Write-Output "Session environment variable has been set"
        return $true
    }
    else {
        Write-Warning "Could not find session key in the output"
        Write-Output $bw_login
        return $false
    }
}

# Authenticate NinjaOne CLI Module
function Start-NOCli {
    [Cmdletbinding()]
    [Alias('nocli')]
    param()
    
    try {
        Invoke-Expression Start-BWCli # Unlock Bitwarden CLI session
        $NOCli = (Invoke-Expression -Command 'bw get item "fd2df932-9e63-4a47-98b1-b2af0044890c"' -ErrorAction Stop) | ConvertFrom-Json
        $fieldValues = @{}
        foreach ($field in $NOCli.fields) {
            if ($field.name -in @("Instance", "ClientID", "ClientSecret", "Scopes")) {
                $fieldValues[$field.name] = $field.value
            }
        }
        $connectParams = @{
            Instance      = $fieldValues["Instance"]
            ClientID      = $fieldValues["ClientID"] 
            ClientSecret  = $fieldValues["ClientSecret"]
            UseClientAuth = $true
            Scopes        = $fieldValues["Scopes"]
            ErrorAction   = 'Stop'
        }
        Connect-NinjaOne @connectParams
    }
    catch {
        Write-Output "Error: $($_.Exception.Message)"
    }
    finally {
        # Ensure Bitwarden vault locks after use
        Invoke-Expression -Command "bw lock" 
    }   
}