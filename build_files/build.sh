#!/bin/bash

set -ouex pipefail

# Copy the contents of system_files/ of the git repo to /
cp -avf "/ctx/system_files"/. /

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/43/x86_64/repoview/index.html&protocol=https&redirect=1

# install fedora packages
dnf5 install -y firefox flatpak plasma-bigscreen 

# enable flathub
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install -y rocks.shy.VacuumTube com.stremio.Stremio tv.plex.PlexHTPC tv.kodi.Kodi io.github.kolunmi.Bazaar

# permission needed to access /etc/bazaar yaml files
flatpak override io.github.kolunmi.Bazaar --filesystem=/etc/bazaar

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable firstboot-autologin.service auto-update.timer

# Prevent sleep, suspend, and hibernation
sudo ln -sf /dev/null /etc/systemd/system/sleep.target
sudo ln -sf /dev/null /etc/systemd/system/suspend.target
sudo ln -sf /dev/null /etc/systemd/system/hibernate.target
sudo ln -sf /dev/null /etc/systemd/system/hybrid-sleep.target

# Create the system-wide WirePlumber configuration directory
mkdir -p /etc/wireplumber/wireplumber.conf.d
# Disable suspend for audio sinks so sound doesn't cut out after idle
cat << 'EOF' > /etc/wireplumber/wireplumber.conf.d/51-disable-suspension.conf
monitor.alsa.rules = [
  {
    matches = [
      {
        node.name = "~alsa_output.*"
      }
    ]
    actions = {
      update-props = {
        session.suspend-timeout-seconds = 0
      }
    }
  }
]
EOF

