#!/usr/bin/env bash
set -oue pipefail

# 1. Enforce flatpak overrides
flatpak override io.github.kolunmi.Bazaar --filesystem=/etc/bazaar

# 2. Enable your system-wide units
systemctl enable firstboot-autologin.service auto-update.timer

# 3. Prevent sleep, suspend, and hibernation states
ln -sf /dev/null /etc/systemd/system/sleep.target
ln -sf /dev/null /etc/systemd/system/suspend.target
ln -sf /dev/null /etc/systemd/system/hibernate.target
ln -sf /dev/null /etc/systemd/system/hybrid-sleep.target

# 4. Create wireplumber configuration to prevent sound cutting off on idle
mkdir -p /etc/wireplumber/wireplumber.conf.d
cat <<'EOF' >/etc/wireplumber/wireplumber.conf.d/51-disable-suspension.conf
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

# 5. Set wallpaper
plasma-apply-wallpaperimage ~/.local/share/wallpapers/jr-korpa-E2i7Hftb_rI-unsplash.jpg
