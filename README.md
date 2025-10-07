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

Run automatically on Windows login (invisible background task):

powershell

`$script = "C:\Tools\SC\SC_Screenshot_Optimizer.ps1"
schtasks /Create /TN "SC Screenshot Optimizer" 
  /TR "powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "$script" -Sources "D:\StarCitizen\PTU\screenshots" -MaxWidth 2560 -Quality 82"
  /SC ONLOGON /RL HIGHEST /F`

---

# 🧪 Example Results
Original	Optimized (WebP)	File Size

`14 MB (JPG)	1.1 MB (WebP 82 %)	− 92 %`

`18 MB (PNG)	1.5 MB (WebP 82 %)	− 91 %`

Visually identical — ideal for web, Discord, and report uploads.

---

# 🗒 Log File

All activity is logged to:

`%LOCALAPPDATA%\SC_Screenshot_Optimizer.log`


