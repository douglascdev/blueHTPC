# blueHTPC

Custom Home Theather PC operating system with Plasma Bigscreen and pre-installed apps, based on bootc/universal blue(the project is NOT affiliated with universal blue, it's just based on their OS)

<img width="1192" height="651" alt="image" src="https://github.com/user-attachments/assets/91742080-a532-4d3c-b099-27020e62ca46" />

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

- `podman`, `just`, `bluebuild`, and `sudo` access (the VM/disk recipes invoke `sudo` themselves where needed)

#### Using Nix flake (recommended)

If you have [Nix](https://nixos.org/download/) installed, use the included `flake.nix` to get all development dependencies automatically:

```bash
nix develop
```

This drops you into a shell with `just`, `bluebuild`, `podman`, `buildah`, `skopeo`, `jq`, `git`, `shellcheck`, `shfmt`, and `findutils` available.

### Clone

```bash
git clone https://github.com/douglascdev/blueHTPC
cd blueHTPC
```

### Build the container image locally

```bash
just build
```

Builds via BlueBuild and tags the image as `localhost/bluehtpc:latest` in your (rootless) podman storage. Run everything as your normal user — the recipes below invoke `sudo` only for the steps that need it.

### Build disk images (ISO / QCOW2)

```bash
# Build ISO (rebuilds container image + ISO in one step)
just rebuild-iso

# Build QCOW2
just rebuild-qcow2
```

### Run the ISO in a VM

```bash
# Build the ISO first
just rebuild-iso
```

Open GNOME Boxes, click **+ → Import Image**, and select `output/bootiso/install.iso`.

The ISO runs the Anaconda installer. Once installed, the VM will boot into blueHTPC with Plasma Bigscreen on each subsequent start.

### Run / rebuild a QCOW2 VM

```bash
# Run the VM (builds the image first if it doesn't exist)
just run-vm

# Rebuild the container image and disk, then run
just rebuild-vm
```

The VM starts a QEMU container with KVM acceleration. Open [http://localhost:8006](http://localhost:8006) in your browser to access the noVNC web interface.

### Maintainers: Testing changes without reinstalling

After installing from the ISO once, you can iterate on changes without rebuilding the ISO:

```bash
# 1. Build the updated image locally
just build

# 2. Push to a test tag (keeps :latest clean for production)
# GH_TOKEN -> a github PAT with write:packages scope
podman login ghcr.io -u login -p "$GH_TOKEN"
podman push localhost/bluehtpc:latest ghcr.io/douglascdev/bluehtpc:testing

# 3. In the VM, switch to the test tag and reboot
sudo bootc switch ghcr.io/douglascdev/bluehtpc:testing
sudo reboot
```

Production systems pinned to `:latest` are unaffected. Once you're satisfied, push to `:latest` for production rollout.

### Customizing

#### Adding packages

Edit `recipes/recipe.yml` — add RPMs to the `rpm-ostree` module and Flatpaks to the `default-flatpaks` module:

```yaml
- type: rpm-ostree
  install:
    - firefox
    - plasma-bigscreen
    - my-new-package

- type: default-flatpaks
  system:
    install:
      - com.example.MyApp
```

#### Adding apps to Bigscreen favorites

Edit `files/etc/skel/.config/bigscreen-favs`. Each entry has an index (`[Favs][N]`) followed by fields describing the app launcher. To add a new app, append a new block with the next index. The `desktopPath` and `entryPath` should match the app's `.desktop` file:

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

Drop files into `files/` mirroring the root filesystem layout. They are copied into the image at build time (via the `files` module in `recipes/recipe.yml`). For example:

- `files/etc/firefox/policies/policies.json` → `/etc/firefox/policies/policies.json`
- `files/usr/lib/systemd/system/my-service.service` → `/usr/lib/systemd/system/my-service.service`

Then enable any new systemd units in `files/scripts/setup-system.sh`:

```bash
systemctl enable my-service.service
```

#### Modifying the ISO installer

Edit `disk_config/iso-kde.toml` to change Anaconda kickstart behavior or installer modules. The `bootc switch` line in the `%post` section determines which image gets installed - update it if you push to a different registry or image name.

#### Building via GitHub Actions

The `build.yml` workflow builds and pushes to GHCR on pull requests and manual dispatch (workflow_dispatch) via the official BlueBuild action. The `build_disk` job then produces ISOs and QCOW2 images as downloadable artifacts.

## Legal Disclaimer

This software is an open-source, non-commercial hobby project. It does not contain age-verification frameworks and is not intended for use by residents of jurisdictions that mandate operating-system-level age verification
