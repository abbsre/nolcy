Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$toolsRoot = Join-Path $scriptRoot '.tools'
$moduleVersion = '1.5.11'
$moduleRoot = Join-Path $toolsRoot "VirtualDesktop.$moduleVersion"
$moduleManifest = Join-Path $moduleRoot 'VirtualDesktop.psd1'
$packageUrl = "https://www.powershellgallery.com/api/v2/package/VirtualDesktop/$moduleVersion"

function Fail([string]$Message) {
    throw $Message
}

function Remove-IfExists([string]$Path) {
    if (Test-Path -LiteralPath $Path) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

try {
    $null = New-Item -ItemType Directory -Path $toolsRoot -Force

    $archivePath = Join-Path $toolsRoot "VirtualDesktop.$moduleVersion.zip"
    $extractRoot = Join-Path $toolsRoot "VirtualDesktop.$moduleVersion.extract"

    Remove-IfExists -Path $archivePath
    Remove-IfExists -Path $extractRoot

    Invoke-WebRequest -Uri $packageUrl -OutFile $archivePath
    Expand-Archive -LiteralPath $archivePath -DestinationPath $extractRoot -Force

    if (-not (Test-Path -LiteralPath (Join-Path $extractRoot 'VirtualDesktop.psd1') -PathType Leaf)) {
        Fail 'La descarga no contiene VirtualDesktop.psd1 en la raiz esperada.'
    }

    Remove-IfExists -Path $moduleRoot
    Move-Item -LiteralPath $extractRoot -Destination $moduleRoot
    Remove-IfExists -Path $archivePath

    if (-not (Test-Path -LiteralPath $moduleManifest -PathType Leaf)) {
        Fail "No se encontro el manifiesto esperado en $moduleManifest"
    }

    Import-Module $moduleManifest -Force -DisableNameChecking | Out-Null

    "VirtualDesktop $moduleVersion listo en $moduleRoot"
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
