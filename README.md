# blueHTPC

Custom Home Theather PC operating system with Plasma Bigscreen and pre-installed apps, based on bootc/universal blue(the project is NOT affiliated with universal blue, it's just based on their OS)

<img width="1192" height="651" alt="image" src="https://github.com/user-attachments/assets/91742080-a532-4d3c-b099-27020e62ca46" />

## Features

- **Kinoite base** - Fedora Kinoite with KDE Plasma
- **Plasma Bigscreen** - TV-friendly 10-foot UI as the default session
- **Auto-login** - Automatically logs into Plasma Bigscreen on first boot after install
- **Pre-installed packages** - Firefox, `plasma-bigscreen`, Flatpak support
- **Pre-installed Flatpaks** - VacuumTube, Plex HTPC, Stremio, Kodi, Bazaar, Flathub remote configured
- **Bigscreen favorites** - All apps pre-pinned to the Plasma Bigscreen home screen
- **uBlock Origin** - Auto-installed in Firefox via enterprise policy
- **Auto-updates** - Daily `bootc upgrade` + `flatpak update` via systemd timer
- **Anaconda ISO** - Full KDE installer with interactive setup (user creation, disk partitioning, etc.)
- **Laptops** - prevent sleep, suspend, and hibernation(lid can be closed while HDMI remains active)
- **Prevent audio from cutting out when returning from idle**

## Quick Start

### Install from ISO

1. Download the latest ISO (GitHub account needed) from the [Actions page](https://github.com/douglascdev/blueHTPC/actions/workflows/build-disk.yml): click the latest run(first on the list) → **Artifacts** or build it (see Dev section).
2. Extract the artifact to get install.iso and use it in [Fedora Media Writer](https://fedoraproject.org/workstation/download/#fedora-media-writer) or a similar program to burn the ISO into a flash drive
3. Boot the ISO and go through the Anaconda installer
4. On first boot, you'll be auto-logged into Plasma Bigscreen

### Switch from an existing bootc system

```bash
sudo bootc switch ghcr.io/douglascdev/bluehtpc:latest
sudo reboot
```

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

## Dev

### Prerequisites

- `podman` and `just` installed
- `sudo` access

#### Using Nix flake (optional)

If you have [Nix](https://nixos.org/download/) installed, you can use the included `flake.nix` to get all development dependencies automatically:

```bash
nix develop
```

This drops you into a shell with `just`, `podman`, `buildah`, `skopeo`, `jq`, `git`, `shellcheck`, and `shfmt` available.

### Clone

```bash
git clone https://github.com/douglascdev/blueHTPC
cd blueHTPC
```

### Build the container image locally

```bash
just build
```

Or build as root (to rebase directly):

```bash
sudo just build
```

### Build disk images (ISO / QCOW2)

```bash
# Build ISO (builds container image + ISO in one step)
sudo just rebuild-iso

# Build QCOW2
sudo just rebuild-qcow2
```

### Run the ISO in a VM

```bash
# Build the ISO first
sudo just rebuild-iso
```

Open GNOME Boxes, click **+ → Import Image**, and select `output/bootiso/install.iso`.

The ISO runs the Anaconda installer. Once installed, the VM will boot into blueHTPC with Plasma Bigscreen on each subsequent start.

### Run / rebuild a QCOW2 VM

```bash
# Run the VM (builds the image first if it doesn't exist)
sudo just run-vm

# Rebuild the container image and disk, then run
sudo just rebuild-vm
```

The VM starts a QEMU container with KVM acceleration and opens a noVNC web interface in your browser.

### Maintainers: Testing changes without reinstalling

After installing from the ISO once, you can iterate on changes without rebuilding the ISO:

```bash
# 1. Build the updated image locally
sudo just build

# 2. Push to a test tag (keeps :latest clean for production)
# GH_TOKEN -> a github PAT with write:packages scope
sudo podman login ghcr.io -u login -p "$GH_TOKEN"
sudo podman push localhost/bluehtpc:latest ghcr.io/douglascdev/bluehtpc:testing

# 3. In the VM, switch to the test tag and reboot
sudo bootc switch ghcr.io/douglascdev/bluehtpc:testing
sudo reboot
```

Production systems pinned to `:latest` are unaffected. Once you're satisfied, push to `:latest` for production rollout.

### Customizing

#### Adding packages

Edit `build_files/build.sh` and add packages to the `dnf5 install` line for RPMs, or a new `flatpak install` line for Flatpaks:

```bash
dnf5 install -y firefox flatpak plasma-bigscreen my-new-package
flatpak install -y com.example.MyApp
```

#### Adding apps to Bigscreen favorites

Edit `system_files/etc/skel/.config/bigscreen-favs`. Each entry has an index (`[Favs][N]`) followed by fields describing the app launcher. To add a new app, append a new block with the next index. The `desktopPath` and `entryPath` should match the app's `.desktop` file:

```ini
[Favs][5]
categories=AudioVideo
comment=My App description
desktopPath=/var/lib/flatpak/exports/share/applications/com.example.MyApp.desktop
entryPath=/usr/bin/flatpak run --branch=stable --arch=x86_64 --command=myapp com.example.MyApp
icon=com.example.MyApp
name=My App
startupNotify=false
storageId=com.example.MyApp.desktop
```

For system (non-Flatpak) apps, `desktopPath` goes under `/usr/share/applications/` and `entryPath` is the command directly.

#### Adding system files

Drop files into `system_files/` mirroring the root filesystem layout. They are copied to `/` during the build. For example:

- `system_files/etc/firefox/policies/policies.json` → `/etc/firefox/policies/policies.json`
- `system_files/usr/lib/systemd/system/my-service.service` → `/usr/lib/systemd/system/my-service.service`

Then enable any new systemd units in `build_files/build.sh`:

```bash
systemctl enable my-service.service
```

#### Modifying the ISO installer

Edit `disk_config/iso-kde.toml` to change Anaconda kickstart behavior or installer modules. The `bootc switch` line in the `%post` section determines which image gets installed - update it if you push to a different registry or image name.

#### Building via GitHub Actions

Push to `main` - the `build.yml` workflow automatically builds and pushes to GHCR. Trigger the `build-disk.yml` workflow manually from the Actions tab to produce ISOs and QCOW2 images as downloadable artifacts.

## Legal Disclaimer

This software is an open-source, non-commercial hobby project. It does not contain age-verification frameworks and is not intended for use by residents of jurisdictions that mandate operating-system-level age verification
