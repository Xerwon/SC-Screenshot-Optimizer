# SC Screenshot Optimizer

A lightweight PowerShell script that automatically optimizes your **Star Citizen** screenshots.  
Whenever a new screenshot appears in one of your screenshot folders, it’s automatically **converted to WebP**, optionally **resized**, and the **original file is deleted**.

Perfect for sharing on Discord, uploading to UEX, or archiving your gameplay shots efficiently.

---

## 🧩 Features

- Watches any number of screenshot folders (LIVE, PTU, EPTU, etc.)
- Supports `.jpg`, `.jpeg`, and `.png`
- Converts to **WebP (quality 78–85%)**
- Optional: scale down to a defined max width (e.g., 2560 px)
- Deletes the original file after successful conversion
- Works on **Windows PowerShell 5.1** and **PowerShell 7+**
- Requires only **ImageMagick** — no extra modules or dependencies

---

## ⚙️ Requirements

- [ImageMagick 7.x](https://imagemagick.org/script/download.php)  
  After installation, check it works by running:
  ```powershell
  magick -version

---

## 📦 Installation

Place the script, e.g.:

`C:\Tools\SC\SC_Screenshot_Optimizer.ps1`


Open the script and set your screenshot paths:

`[string[]]$Sources = @(
"D:\StarCitizen\LIVE\screenshots",
"D:\StarCitizen\PTU\screenshots"
)`

(Optional) adjust image quality or max width:

`[int]$MaxWidth = 2560`

`[int]$Quality  = 82`

---

## ▶️ Manual Run

`powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Tools\SC\SC_Screenshot_Optimizer.ps1"`

Keep the PowerShell window open — it will poll the folder every 2 seconds and optimize new screenshots.

 ---

## 🚀 Autostart (Recommended)

You can make the optimizer run automatically every time you log in to Windows —
no need to keep PowerShell open manually.

### 🔧 Variant 1 – Install the Autostart Task

Use the included helper script `install-task.ps1`.
It creates (or updates) a Windows Scheduled Task that launches the optimizer invisibly at login with elevated privileges.

.\scripts\install-task.ps1 `
  -ScriptPath "C:\Tools\SC\SC_Screenshot_Optimizer.ps1" `
  -Sources "D:\StarCitizen\PTU\screenshots","D:\StarCitizen\LIVE\screenshots" `
  -MaxWidth 2560 `
  -Quality 82


✅ What this does

Registers the task “SC Screenshot Optimizer” in Windows Task Scheduler

Trigger: At log on

Runs PowerShell hidden and with highest privileges

Starts the optimizer once immediately for testing

Requests administrator rights automatically (UAC prompt)

### 🧹 Variant 2 – Uninstall the Task

If you want to remove the background task later —
for example when changing your folder setup — run:

.\scripts\uninstall-task.ps1 -TaskName "SC Screenshot Optimizer" -StopRunning


✅ What this does

Stops any currently running instance (optional with -StopRunning)

Deletes the task from Windows Task Scheduler

Requests elevation automatically if needed

### 🧪 Test and Verify

Run the task manually (no restart required):

schtasks /Run /TN "SC Screenshot Optimizer"


Check task details and last run time:

schtasks /Query /TN "SC Screenshot Optimizer" /V /FO LIST

---

## 🧪 Example Results
Original	Optimized (WebP)	File Size

`14 MB (JPG)	1.1 MB (WebP 82 %)	− 92 %`

`18 MB (PNG)	1.5 MB (WebP 82 %)	− 91 %`

Visually identical — ideal for web, Discord, and report uploads.

---

## 🗒 Log File

All activity is logged to:

`%LOCALAPPDATA%\SC_Screenshot_Optimizer.log`


