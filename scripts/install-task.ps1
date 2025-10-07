param(
  [Parameter(Mandatory=$true)]
  [string]$ScriptPath,                             # Pfad zu SC_Screenshot_Optimizer.ps1

  [Parameter(Mandatory=$true)]
  [string[]]$Sources,                              # Ein oder mehrere Screenshot-Ordner

  [int]$MaxWidth = 2560,
  [int]$Quality  = 82,
  [string]$TaskName = "SC Screenshot Optimizer"
)

# --- UAC: Selbstelevation ---
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

# --- Validierung ---
if (-not (Test-Path -LiteralPath $ScriptPath)) { throw "ScriptPath not found: $ScriptPath" }
if ($Sources.Count -eq 0) { throw "At least one -Sources path required." }

# Quoting der Sources für die Übergabe an den Task (PowerShell-Aufruf in cmd-Kontext)
# Ergebnis wie: "D:\StarCitizen\PTU\screenshots","D:\StarCitizen\LIVE\screenshots"
$quotedSources = ($Sources | ForEach-Object { '"' + $_ + '"' }) -join ','

# Task-Argumente sauber zusammensetzen
# Achtung: Alles was nach /TR kommt, läuft im cmd-Kontext -> Quotes exakt setzen
$psArgs = '-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden ' +
          '-File "{0}" -Sources {1} -MaxWidth {2} -Quality {3}' -f $ScriptPath, $quotedSources, $MaxWidth, $Quality

# Existierenden Task ggf. ersetzen
$null = schtasks /Delete /TN "$TaskName" /F 2>$null

# Task erstellen
$create = schtasks /Create /TN "$TaskName" /TR "powershell.exe $psArgs" /SC ONLOGON /RL HIGHEST /F
if ($LASTEXITCODE -ne 0) { throw "Failed to create task. schtasks output: `n$create" }

Write-Host "Task '$TaskName' installed."
Write-Host "Trigger: On logon, Run with highest privileges."
Write-Host "Action : powershell.exe $psArgs"

# Optional: direkt starten zum Test
try {
  $null = schtasks /Run /TN "$TaskName"
  Write-Host "Task started for testing."
} catch {
  Write-Warning "Task created, but could not start immediately. You can start it via Task Schedul
