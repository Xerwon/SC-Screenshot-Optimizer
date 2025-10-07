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


## ▶️ Manual Run

`powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Tools\SC\SC_Screenshot_Optimizer.ps1"`

Keep the PowerShell window open — it will poll the folder every 2 seconds and optimize new screenshots.


## 🚀 Autostart (Recommended)

You can make the optimizer run automatically every time you log in to Windows —
no need to keep PowerShell open manually.


### 🔧 Install the Autostart Task


1️⃣ Open PowerShell as Administrator

2️⃣ Change directory

`cd "C:\Tools\SC"`


3️⃣ Unblock downloaded scripts

`Get-ChildItem . | Unblock-File`


4️⃣ Run the installer

`.\install-task.ps1 -ScriptPath "C:\Tools\SC\SC_Screenshot_Optimizer.ps1"`


✅ This creates the Windows scheduled task
“SC Screenshot Optimizer” that runs automatically on every login — hidden and elevated.


### 🧪 Verify & Test — What to expect

✅ Verify (after installing the task)

1️⃣ Open PowerShell as Administrator
Run:
`schtasks /Query /TN "SC Screenshot Optimizer" /V /FO LIST`

You should see:

- `TaskName: \SC Screenshot Optimizer`
- `Status: is running`
- `Run as User: <your user>`
- `Logon Mode: Interactive/Background` (wording varies)

You should **NOT** see:

- `ERROR: The system cannot find the file specified.` → Wrong -ScriptPath in install.
- `Last Run Result: 0x1` or other non-zero codes → Usually quoting/permissions/path issues.
- A different user in `Run as User` (e.g., SYSTEM) unless you intended that.

▶️ Test (start it manually)

1️⃣ Open PowerShell as Administrator
Run:
`schtasks /Run /TN "SC Screenshot Optimizer"`

You should see:
- The command returns quickly (no error).
- `INFORMATION: The scheduled task “SC Screenshot Optimizer” is currently running.`
- `SUCCESS: An attempt was made to execute the scheduled task “SC Screenshot Optimizer.”`
- The log file is created/updated:
  - If your script logs to `%LOCALAPPDATA%`:
  - `%LOCALAPPDATA%\SC_Screenshot_Optimizer.log`
- If you changed it to the script folder, check there instead.
- Log contains lines like:
  - `Polling started: D:\StarCitizen\PTU\screenshots, ...`
  - `OK : <name>.webp` after you create a fresh JPG/PNG in a watched folder.
  
You should NOT see:

- A blocking PowerShell window that never returns (task runs hidden; the query/ run commands should return).
- No log entry at all after you drop a new screenshot into the watched folder.
- Repeated `FAIL:` or `DEL FAIL:` lines (indicates conversion/permissions issues).
- `.jpg` files staying forever alongside `.webp` after a fresh screenshot (means conversion or delete failed).


### 🧰 Quick live test (without launching the game)

**1.** Make a dummy file in a watched folder:
   `Set-Content -Path "D:\StarCitizen\PTU\screenshots\_test.jpg" -Value "x"`
   
**2.** Wait up to 2–3 seconds (polling interval).

**3. Expected result:**
  - `_test.webp` appears
  - `_test.jpg` is deleted
  - Log shows `OK : _test.webp`

**4. If not:**
  - Check that the folder path in your optimizer script matches the one you’re testing.
  - Run magick -version in PowerShell to ensure ImageMagick is on PATH.
  - Open the log and look for FAIL messages (quoting them in an issue helps).


### 🚨 Common pitfalls & fixes

- **No log file appears**
  - You’re looking in the wrong place (different user account or different log path).
  - The task didn’t actually start. Re-run `schtasks /Run /TN ...` and query status.
  - If you run the task as SYSTEM, the log may be under the SYSTEM profile.
   
- **“Last Run Result: 0x1”**
   - Usually bad quoting or wrong `ScriptPath`. Reinstall with the exact path.
   - Ensure the script isn’t blocked: `Unblock-File C:\Tools\SC\SC_Screenshot_Optimizer.ps1`.
    
- **Conversion doesn’t happen**
   - Verify the file extension is supported (`.jpg`, `.jpeg`, `.png`).
   - Ensure `magick` is available: `magick -version`.
   - Check the script’s $Sources actually include the folder you’re testing.
    
- **Files exist but never get processed**
   - Your script uses a **polling loop** (default 2 seconds). Give it a moment.
   - Check timestamps: files are only reprocessed if source is newer than target.
   - Try with a new file: create or copy a fresh `.jpg` to the folder.

- **Task created under the wrong user**
   - Reinstall from an elevated PowerShell opened under the intended account.
   - In Task Scheduler, confirm “**Run only when user is logged on**” (for debugging) and “**Run with highest privileges.**”

---

## 🧹 Uninstall

`.\uninstall-task.ps1 -StopRunning`

✅ Stops and removes the task completely.

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


