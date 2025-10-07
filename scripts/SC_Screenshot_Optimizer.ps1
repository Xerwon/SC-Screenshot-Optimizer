param(
  [string[]]$Sources =@(
  "D:\StarCitizen\PTU\screenshots",
  "D:\StarCitizen\LIVE\screenshots" # add more folders here
),  
  [int]$MaxWidth = 2560,  # 0 = no resizing
  [int]$Quality  = 82     # 78–85 is a good sweet spot
)

# --- Locate ImageMagick (compatible with Windows PowerShell 5.1) ---
$MagickCmd = $null
$cmd = Get-Command magick -ErrorAction SilentlyContinue
if ($cmd) { $MagickCmd = $cmd.Source }
if (-not $MagickCmd) {
  $candidates = @(
    "C:\Program Files\ImageMagick-7.1.2-Q16-HDRI\magick.exe",
    "C:\Program Files\ImageMagick-7.1.1-Q16-HDRI\magick.exe",
    "C:\Program Files\ImageMagick-7.1.0-Q16-HDRI\magick.exe"
  )
  foreach ($c in $candidates) { if (Test-Path $c) { $MagickCmd = $c; break } }
}
if (-not $MagickCmd) { Write-Host "ImageMagick nicht gefunden."; exit 1 }

$Log = "$env:LOCALAPPDATA\SC_Screenshot_Optimizer.log"
function Log($m){ "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  $m" | Out-File -FilePath $Log -Append -Encoding UTF8 }

function IsSupported([string]$p){
  $e = ([IO.Path]::GetExtension($p)).ToLower()
  return ($e -eq ".jpg" -or $e -eq ".jpeg" -or $e -eq ".png")
}

function NeedsProcess([IO.FileInfo]$f){
  $dst = Join-Path $f.DirectoryName ($f.BaseName + ".webp")
  if (!(Test-Path -LiteralPath $dst)) { return $true }
  $dstTime = (Get-Item -LiteralPath $dst).LastWriteTimeUtc
  return ($dstTime -lt $f.LastWriteTimeUtc)
}

function ResizeArg($w){ if($w -gt 0){"$($w)x>"} }

function Convert-One([IO.FileInfo]$f){
  $src = $f.FullName
  $dst = Join-Path $f.DirectoryName ($f.BaseName + ".webp")
  $args = @($src, "-strip")
  $r = ResizeArg $MaxWidth; if ($r) { $args += @("-resize",$r) }
  $args += @("-define","webp:method=6","-quality",$Quality,$dst)

  & $MagickCmd @args
  if ($LASTEXITCODE -eq 0) {
    try { Remove-Item -LiteralPath $src -Force } catch { Log "DEL FAIL: $src - $($_.Exception.Message)"; return }
    Log "OK  : $(Split-Path $dst -Leaf) in $(Split-Path $f.DirectoryName -Leaf)"
    Write-Host "OK  : $($f.Name) -> $(Split-Path $dst -Leaf)"
  } else {
    Log "FAIL: $($f.Name)"
    Write-Host "FAIL: $($f.Name)"
  }
}

# --- Setup & Polling-Loop ---
foreach ($s in $Sources) {
  if (!(Test-Path $s)) { New-Item -ItemType Directory -Force -Path $s | Out-Null }
}
Log "Polling gestartet: $($Sources -join ', ')  (MaxWidth=$MaxWidth, Quality=$Quality)"

while ($true) {
  foreach ($s in $Sources) {
    # robustes Listing (kein -Include Bug)
    Get-ChildItem -Path "$s\*" -File -ErrorAction SilentlyContinue |
      Where-Object { IsSupported $_.FullName } |
      Where-Object { NeedsProcess $_ } |
      ForEach-Object { Convert-One $_ }
  }
  Start-Sleep -Milliseconds 2000
}
