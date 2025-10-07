param(
  [Parameter(Mandatory=$true)]
  [string]$ScriptPath,                             # Path to SC_Screenshot_Optimizer.ps1

  [Parameter(Mandatory=$true)]
  [string[]]$Sources,                              # One or more screenshot folders

  [int]$MaxWidth = 2560,
  [int]$Quality  = 82,
  [string]$TaskName = "SC Screenshot Optimizer"
)

# --- UAC: Self-Elevation ---
$IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $IsAdmin) {
  Write-Host "Requesting elevation..."
  $psi = New-Object System.Diagnostics.ProcessStartInfo
  $psi.FileName = "powershell.exe"
  $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" " +
                   "-ScriptPath `"$ScriptPath`" " +
                   "-Sources " + (($Sources | ForEach-Object { "`"`$_`"" }) -join ' , ') + " " +
                   "-MaxWidth $MaxWidth -Quality $Quality -TaskName `"$TaskName`""
  $psi.Verb = "runas"
  try { [Diagnostics.Process]::Start($psi) | Out-Null } catch { throw "Elevation cancelled." }
  exit
}

# --- Validation ---
if (-not (Test-Path -LiteralPath $ScriptPath)) { throw "ScriptPath not found: $ScriptPath" }
if ($Sources.Count -eq 0) { throw "At least one -Sources path required." }

# Quote the sources for passing to the task (PowerShell call inside cmd context)
# Result example: "D:\StarCitizen\PTU\screenshots","D:\StarCitizen\LIVE\screenshots"
$quotedSources = ($Sources | ForEach-Object { '"' + $_ + '"' }) -join ','

# Build clean argument string
# Note: Everything after /TR executes in cmd context, so quoting must be exact
$psArgs = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden ' +
          '-File "{0}" -Sources {1} -MaxWidth {2} -Quality {3}' -f $ScriptPath, $quotedSources, $MaxWidth, $Quality

# Replace existing task if present
$null = schtasks /Delete /TN "$TaskName" /F 2>$null

# Create task
$create = schtasks /Create /TN "$TaskName" /TR "powershell.exe $psArgs" /SC ONLOGON /RL HIGHEST /F
if ($LASTEXITCODE -ne 0) { throw "Failed to create task. schtasks output: `n$create" }

Write-Host "Task '$TaskName' installed."
Write-Host "Trigger: On logon, Run with highest privileges."
Write-Host "Action : powershell.exe $psArgs"

# Optionally start it right away for testing
try {
  $null = schtasks /Run /TN "$TaskName"
  Write-Host "Task started for testing."
} catch {
  Write-Warning "Task created, but could not start immediately. You can start it via Task Schedul

