#!/bin/bash
USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
if [ -n "$USER" ]; then
  mkdir -p /etc/sddm.conf.d
  cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=$USER
Session=plasma-bigscreen-wayland.desktop
EOF
fi
systemctl disable firstboot-autologin.service
