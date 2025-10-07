param(
  [string]$TaskName = "SC Screenshot Optimizer",
  [switch]$StopRunning                          # optional: laufende Instanz beenden
)

# --- UAC: Selbstelevation ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $IsAdmin) {
  Write-Host "Requesting elevation..."
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell.exe"
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -TaskName `"$TaskName`" " + ($StopRunning.IsPresent ? "-StopRunning" : "")
  $psi.Verb = "runas"
  try { [Diagnostics.Process]::Start($psi) | Out-Null } catch { throw "Elevation cancelled." }
  exit
}

# Optional laufende Instanz beenden (rudimentär über Aufgabenplanung)
if ($StopRunning) {
  try {
    $null = schtasks /End /TN "$TaskName" 2>$null
    Write-Host "Stopped running task instance (if any)."
  } catch {
    Write-Host "No running instance to stop (or stop failed)."
  }
}

# Task löschen
try {
  $out = schtasks /Delete /TN "$TaskName" /F 2>&1
  Write-Host "Task '$TaskName' removed."
} catch {
  Write-Warning "Failed to delete task '$TaskName'. It may not exist."
}
