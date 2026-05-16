Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceFile = Join-Path $scriptRoot 'Nocly.cs'
$outputFile = Join-Path $scriptRoot 'Nocly.exe'
$pdbFile = Join-Path $scriptRoot 'Nocly.pdb'
$compilerPath = Join-Path $env:WINDIR 'Microsoft.NET\Framework64\v4.0.30319\csc.exe'

function Fail([string]$Message) {
    throw $Message
}

try {
    if (-not (Test-Path -LiteralPath $sourceFile -PathType Leaf)) {
        Fail "No se encontro el codigo fuente en $sourceFile"
    }

    if (-not (Test-Path -LiteralPath $compilerPath -PathType Leaf)) {
        Fail "No se encontro el compilador esperado en $compilerPath"
    }

    if (Test-Path -LiteralPath $outputFile) {
        Remove-Item -LiteralPath $outputFile -Force
    }

    if (Test-Path -LiteralPath $pdbFile) {
        Remove-Item -LiteralPath $pdbFile -Force
    }

    & $compilerPath /nologo /target:winexe /out:$outputFile /reference:System.Windows.Forms.dll /reference:System.Drawing.dll $sourceFile

    if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
        Fail "La compilacion no genero $outputFile"
    }

    "Desktop app listo en $outputFile"
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
