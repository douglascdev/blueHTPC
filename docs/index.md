---
layout: default
---

Custom Home Theather PC operating system with Plasma Bigscreen and pre-installed apps, based on bootc/universal blue(the project is NOT affiliated with universal blue, it's just based on their OS)

<img width="1192" height="651" alt="image" src="https://github.com/user-attachments/assets/91742080-a532-4d3c-b099-27020e62ca46" />
<img width="840" height="318" alt="image" src="https://github.com/user-attachments/assets/887ada88-0d33-4097-971b-c5213077b55c" />

## Features

- **Kinoite base** - Fedora Kinoite with KDE Plasma
- **Plasma Bigscreen** - TV-friendly 10-foot UI as the default session
- **Auto-login** - Automatically logs into Plasma Bigscreen on first boot after install
- **Pre-installed packages** - Firefox, `plasma-bigscreen`, Flatpak support
- **Pre-installed Flatpaks** - Plex HTPC, Stremio, Kodi, Nuvio, VacuumTube, Bazaar, Flathub remote configured
- **Bigscreen favorites** - All apps pre-pinned to the Plasma Bigscreen home screen
- **uBlock Origin** - Auto-installed in Firefox via enterprise policy
- **Auto-updates** - Daily `bootc upgrade` + `flatpak update` via systemd timer
- **Anaconda ISO** - Full KDE installer with interactive setup (user creation, disk partitioning, etc.)
- **Laptops** - prevent sleep, suspend, and hibernation(lid can be closed while HDMI remains active)
- **Prevent audio from cutting out when returning from idle**

## Quick Start

### Install from ISO

1. Download the latest ISO parts from the [releases page](https://github.com/douglascdev/blueHTPC)(you need to download all the files)
2. Extract the .zip file using WinRAR, 7-Zip, etc(on Linux you can: `7z x blueHTPC-v0.0.1.zip` replacing v0.0.1 with the latest version)
3. Use the ISO in [Fedora Media Writer](https://fedoraproject.org/workstation/download/#fedora-media-writer) or a similar program to burn the ISO into a flash drive
4. Boot the ISO and go through the Anaconda installer
5. On first boot, you'll be auto-logged into Plasma Bigscreen
6. The icons are going to be blank because the flatpaks are installing, wait like 5 minutes and restart.

## Installing New Apps

Use **Bazaar** (pre-installed) to install additional applications. Bazaar is a Flatpak app store that lets you browse and install apps from Flathub.

- Launch **Bazaar** from the Plasma Bigscreen home screen
- Browse a **curated section** with **frequently installed apps** (Jellyfin, Steam, Discord, Spotify, Heroic Games Launcher, Lutris, RetroArch, ProtonPlus, VLC, Flatseal, Steam Link, Dolphin, and Protontricks) for one-click installs
- Search Flathub for any other app you want

## KDE Connect Remote

Plasma Bigscreen includes a built-in **TV Remote** interface that pairs with [KDE Connect](https://kdeconnect.kde.org/) on your phone.

### Pairing

1. Install KDE Connect on your phone (available on [Google Play](https://play.google.com/store/apps/details?id=org.kde.kdeconnect_tp))
2. Ensure both devices are on the same network
3. On the Bigscreen home screen, click the phone icon and select your phone
4. Open KDE Connect on your phone and tap the blueHTPC entry when it appears
5. Accept the pairing request on both devices

Once paired, the remote control will appear automatically — you can navigate with touch, swipe for mouse mode, and use the keyboard tab for text input.

