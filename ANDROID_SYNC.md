# Syncing Obsidian Vault with Syncthing on Android

This document explains how to set up a reliable, free synchronization between a Windows PC and an Android device using Syncthing.

## Why Syncthing?

- Completely free
- No cloud required
- Works perfectly with Obsidian
- Reliable even on Samsung / OneUI devices
- No Termux or Git needed

## Steps

### 1. Install Syncthing
- On Android: install **Syncthing-Fork** from Play Store.
- On Windows: download Syncthing from https://syncthing.net/downloads/

### 2. Create a dedicated Obsidian vault folder
On Android, inside Syncthing, create:

/storage/emulated/0/Syncthing/ObsidianVault

This folder is 100% safe and can always be opened by Obsidian (no SAF issues).

### 3. Sync the folder
- Add the folder in Syncthing on both devices.
- Accept the share on the other device.

### 4. Use it in Obsidian
- On Android: “Use existing vault” → select `Syncthing/ObsidianVault`
- On Windows: open the same folder as vault.

## Result
Your Obsidian vault will sync automatically between PC and Android, completely free, securely, and without any special permissions or apps.
