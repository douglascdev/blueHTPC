# blueHTPC

Custom bootc-based Home Theater PC image built on Kinoite with Plasma Bigscreen.

## Features

- **Kinoite base** — Fedora Kinoite with KDE Plasma
- **Plasma Bigscreen** — TV-friendly 10-foot UI as the default session
- **Auto-login** — Automatically logs into Plasma Bigscreen on first boot after install
- **Pre-installed packages** — Firefox, `plasma-bigscreen`, Flatpak support
- **Pre-installed Flatpaks** — VacuumTube, Flathub remote configured
- **uBlock Origin** — Auto-installed in Firefox via enterprise policy
- **Auto-updates** — Daily `bootc upgrade` + `flatpak update` via systemd timer
- **Anaconda ISO** — Full KDE installer with interactive setup (user creation, disk partitioning, etc.)

## Quick Start

### Install from ISO

1. Build the ISO (see Dev section), or download from GitHub Actions artifacts
2. Boot the ISO and go through the Anaconda installer
3. On first boot, you'll be auto-logged into Plasma Bigscreen

### Switch from an existing bootc system

```bash
sudo bootc switch ghcr.io/douglascdev/bluehtpc:latest
sudo reboot
```

## Dev

### Prerequisites

- `podman` and `just` installed
- `sudo` access

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

# Then open it in GNOME Boxes
boxes output/bootiso/install.iso
```

Alternatively open GNOME Boxes, click **+ → Import Image**, and select `output/bootiso/install.iso`.

The ISO runs the Anaconda installer. Once installed, the VM will boot into blueHTPC with Plasma Bigscreen on each subsequent start.

### Maintaners: Testing changes without reinstalling

After installing from the ISO once, you can iterate on changes without rebuilding the ISO:

```bash
# 1. Build the updated image locally
sudo just build

# 2. Push to a test tag (keeps :latest clean for production)
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

#### Adding system files

Drop files into `system_files/` mirroring the root filesystem layout. They are copied to `/` during the build. For example:

- `system_files/etc/firefox/policies/policies.json` → `/etc/firefox/policies/policies.json`
- `system_files/usr/lib/systemd/system/my-service.service` → `/usr/lib/systemd/system/my-service.service`

Then enable any new systemd units in `build_files/build.sh`:

```bash
systemctl enable my-service.service
```

#### Modifying the ISO installer

Edit `disk_config/iso-kde.toml` to change Anaconda kickstart behavior or installer modules. The `bootc switch` line in the `%post` section determines which image gets installed — update it if you push to a different registry or image name.

#### Building via GitHub Actions

Push to `main` — the `build.yml` workflow automatically builds and pushes to GHCR. Trigger the `build-disk.yml` workflow manually from the Actions tab to produce ISOs and QCOW2 images as downloadable artifacts.
