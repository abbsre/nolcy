param(
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Add-Type -AssemblyName System.Windows.Forms

$virtualDesktopVersion = '1.5.11'
$toolsRoot = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) '.tools'
$virtualDesktopRoot = Join-Path $toolsRoot "VirtualDesktop.$virtualDesktopVersion"
$virtualDesktopManifest = Join-Path $virtualDesktopRoot 'VirtualDesktop.psd1'

Add-Type @"
using System;
using System.Runtime.InteropServices;

public static class NativeWindow {
    [DllImport("user32.dll")]
    public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);
}
"@

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$pathFile = Join-Path $scriptRoot 'path.txt'

function Fail([string]$Message) {
    throw $Message
}

function Get-WorkingDirectory {
    if (-not (Test-Path -LiteralPath $pathFile -PathType Leaf)) {
        Fail "No se encontro path.txt en $scriptRoot. Crea ese archivo con la ruta del proyecto."
    }

    $workingDirectory = [System.IO.File]::ReadAllText($pathFile).Trim()

    if ([string]::IsNullOrWhiteSpace($workingDirectory)) {
        Fail 'path.txt esta vacio. Escribe una ruta valida.'
    }

    if (-not (Test-Path -LiteralPath $workingDirectory -PathType Container)) {
        Fail "La ruta definida en path.txt no existe: $workingDirectory"
    }

    return $workingDirectory
}

function Assert-CommandAvailable([string]$CommandName) {
    if (-not (Get-Command $CommandName -ErrorAction SilentlyContinue)) {
        Fail "El comando '$CommandName' no esta disponible en PATH."
    }
}

function Import-VirtualDesktopModule {
    if (Test-Path -LiteralPath $virtualDesktopManifest -PathType Leaf) {
        Import-Module $virtualDesktopManifest -Force -DisableNameChecking | Out-Null
        return
    }

    if (Get-Module -ListAvailable -Name 'VirtualDesktop') {
        Import-Module 'VirtualDesktop' -Force -DisableNameChecking | Out-Null
        return
    }

    Fail "No se encontro el modulo VirtualDesktop. Ejecuta setup-virtualdesktop.bat o deja disponible $virtualDesktopManifest antes de ejecutar el launcher."
}

function Assert-DesktopCount([int]$RequiredCount) {
    $currentCount = Get-DesktopCount

    if ($currentCount -lt $RequiredCount) {
        Fail "Solo hay $currentCount escritorio(s) virtual(es). Crea manualmente al menos $RequiredCount escritorios antes de ejecutar el launcher."
    }
}

function Get-DesktopByNumber([int]$DesktopNumber) {
    if ($DesktopNumber -lt 1) {
        Fail 'Los escritorios comienzan en 1.'
    }

    return Get-Desktop ($DesktopNumber - 1)
}

function Wait-ForMainWindow([System.Diagnostics.Process]$Process, [int]$TimeoutSeconds = 20) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)

    while ((Get-Date) -lt $deadline) {
        if ($Process.HasExited) {
            Fail "La consola para PID $($Process.Id) se cerro antes de mostrar una ventana."
        }

        $Process.Refresh()

        if ($Process.MainWindowHandle -ne [IntPtr]::Zero) {
            return $Process.MainWindowHandle
        }

        Start-Sleep -Milliseconds 250
    }

    Fail "No se pudo obtener la ventana principal del proceso PID $($Process.Id)."
}

function Start-ToolConsole(
    [string]$ToolName,
    [string]$WorkingDirectory,
    [string]$WindowTitle,
    [string]$WindowStyle = 'Normal',
    [string]$ToolCommand = $null,
    [string]$BeforeCommand = $null,
    [string]$HostExecutable = 'powershell.exe'
) {
    $escapedDirectory = $WorkingDirectory.Replace("'", "''")
    $escapedTitle = $WindowTitle.Replace("'", "''")
    $effectiveCommand = if ([string]::IsNullOrWhiteSpace($ToolCommand)) { $ToolName } else { $ToolCommand }

    if ($DryRun) {
        return [pscustomobject]@{
            ToolName = $ToolName
            Process = $null
            Handle = [IntPtr]::Zero
            Title = $WindowTitle
            WindowStyle = $WindowStyle
        }
    }

    if ($HostExecutable -eq 'cmd.exe') {
        $cmdSegments = @(
            "title $WindowTitle"
            "cd /d `"$WorkingDirectory`""
            $effectiveCommand
        )

        $cmdCommand = ($cmdSegments -join ' & ')

        $process = Start-Process -FilePath 'cmd.exe' `
            -ArgumentList @('/k', $cmdCommand) `
            -WorkingDirectory $WorkingDirectory `
            -WindowStyle $WindowStyle `
            -PassThru
    }
    else {
        $segments = @(
            "`$Host.UI.RawUI.WindowTitle = '$escapedTitle'"
            "Set-Location -LiteralPath '$escapedDirectory'"
        )

        if (-not [string]::IsNullOrWhiteSpace($BeforeCommand)) {
            $segments += $BeforeCommand
        }

        $segments += $effectiveCommand
        $command = ($segments -join '; ')

        $process = Start-Process -FilePath 'powershell.exe' `
            -ArgumentList @('-NoExit', '-ExecutionPolicy', 'Bypass', '-Command', $command) `
            -WorkingDirectory $WorkingDirectory `
            -WindowStyle $WindowStyle `
            -PassThru
    }

    $handle = Wait-ForMainWindow -Process $process

    return [pscustomobject]@{
        ToolName = $ToolName
        Process = $process
        Handle = $handle
        Title = $WindowTitle
        WindowStyle = $WindowStyle
    }
}

function Set-WindowRect([IntPtr]$Handle, [int]$X, [int]$Y, [int]$Width, [int]$Height) {
    [void][NativeWindow]::ShowWindow($Handle, 1)
    [void][NativeWindow]::MoveWindow($Handle, $X, $Y, $Width, $Height, $true)
}

function Set-WindowMaximized([IntPtr]$Handle) {
    [void][NativeWindow]::ShowWindow($Handle, 3)
}

function Move-WindowToDesktop([IntPtr]$Handle, $Desktop) {
    if ($Handle -eq [IntPtr]::Zero) {
        Fail 'No se puede mover una ventana sin handle.'
    }

    $Handle | Move-Window $Desktop | Out-Null
}

function Set-WorkspaceDesktops([array]$Windows) {
    $desktop1 = Get-DesktopByNumber 1
    $desktop2 = Get-DesktopByNumber 2
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
    $halfWidth = [Math]::Floor($screen.Width / 2)
    $rightWidth = $screen.Width - $halfWidth

    Move-WindowToDesktop -Handle $Windows[0].Handle -Desktop $desktop1
    Move-WindowToDesktop -Handle $Windows[1].Handle -Desktop $desktop1
    Move-WindowToDesktop -Handle $Windows[2].Handle -Desktop $desktop2

    $desktop1 | Switch-Desktop | Out-Null
    Start-Sleep -Milliseconds 300
    Set-WindowRect -Handle $Windows[0].Handle -X $screen.X -Y $screen.Y -Width $halfWidth -Height $screen.Height
    Set-WindowRect -Handle $Windows[1].Handle -X ($screen.X + $halfWidth) -Y $screen.Y -Width $rightWidth -Height $screen.Height

    $desktop2 | Switch-Desktop | Out-Null
    Start-Sleep -Milliseconds 300
    Set-WindowMaximized -Handle $Windows[2].Handle
    [void][NativeWindow]::SetForegroundWindow($Windows[2].Handle)
}

try {
    $workingDirectory = Get-WorkingDirectory

    foreach ($tool in @('opencode', 'lazygit', 'nvim')) {
        Assert-CommandAvailable -CommandName $tool
    }

    Import-VirtualDesktopModule
    Assert-DesktopCount -RequiredCount 2

    $windows = @(
        Start-ToolConsole -ToolName 'opencode' -WorkingDirectory $workingDirectory -WindowTitle 'opencode' -WindowStyle 'Normal'
        Start-ToolConsole -ToolName 'lazygit' -WorkingDirectory $workingDirectory -WindowTitle 'lazygit' -WindowStyle 'Normal' -HostExecutable 'cmd.exe'
        Start-ToolConsole -ToolName 'nvim' -WorkingDirectory $workingDirectory -WindowTitle 'nvim' -WindowStyle 'Maximized' -ToolCommand 'nvim .'
    )

    if ($DryRun) {
        'Dry run completado. path.txt, comandos y plan de escritorios validados.'
    }
    else {
        Set-WorkspaceDesktops -Windows $windows
    }

    $windows | Format-Table ToolName, Title, WindowStyle -AutoSize
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
