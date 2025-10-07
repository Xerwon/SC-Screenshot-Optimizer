param(
  [Parameter(Mandatory=$true)]
  [string]$ScriptPath,                             # Path to SC_Screenshot_Optimizer.ps1

  [string]$TaskName = "SC Screenshot Optimizer"
)

# --- UAC: Self-Elevation ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $IsAdmin) {
  Write-Host "Requesting elevation..."
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell.exe"
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -ScriptPath `"$ScriptPath`" -TaskName `"$TaskName`""
  $psi.Verb = "runas"
  try { [Diagnostics.Process]::Start($psi) | Out-Null } catch { throw "Elevation cancelled." }
  exit
}

# --- Validation ---
if (-not (Test-Path -LiteralPath $ScriptPath)) { throw "ScriptPath not found: $ScriptPath" }

# --- Build clean argument string ---
$psArgs = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""

# --- Replace existing task if present ---
$null = schtasks /Delete /TN "$TaskName" /F 2>$null

# --- Create new task ---
$create = schtasks /Create /TN "$TaskName" /TR "powershell.exe $psArgs" /SC ONLOGON /RL HIGHEST /F
if ($LASTEXITCODE -ne 0) { throw "Failed to create task. schtasks output:`n$create" }

Write-Host "Task '$TaskName' installed."
Write-Host "Trigger : On logon, run with highest privileges."
Write-Host "Action  : powershell.exe $psArgs"

# --- Start once for testing ---
try {
  $null = schtasks /Run /TN "$TaskName"
  Write-Host "Task started for testing."
} catch {
  Write-Warning "Task created, but could not start immediately. You can start it manually via Task Scheduler."
}
