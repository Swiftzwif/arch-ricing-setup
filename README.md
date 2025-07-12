# Swift Arch Ricing & Migration Toolkit

## Overview
This toolkit helps you migrate to and rice your new Arch Linux setup with i3, developer tools, custom theming, and a beautiful, keyboard-driven workflow. Firefox will be installed as a fresh app (no profile migration).

## How to Use

### 1. Format Your USB (Optional)
Run:
```bash
sudo ./format-usb.sh
```
Follow the prompts to select and format your USB drive as exFAT.

### 2. Backup Your Data on Pop!_OS
Copy your Documents, code projects, dotfiles, and configs to the USB.

### 3. Install and Migrate on Arch
Run:
```bash
sudo ./swift-arch-setup.sh
```
Follow the prompts to install all apps, apply theming, and restore your data.

### 4. Access the Cheat Sheet
Press `Super+P` in i3 to see all your shortcuts in a pop-up.

---

**Troubleshooting:**  
- All scripts log actions and errors to `~/swift-arch-setup.log`.
- If you encounter issues, check the log or re-run the script with `--dry-run` for a preview.

---

## Notes
- Firefox will be installed as a fresh app. If you want to migrate bookmarks or settings, use Firefox Sync or export/import features manually. 