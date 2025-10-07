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
