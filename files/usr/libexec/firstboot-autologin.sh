#!/bin/bash
USER=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1; exit}' /etc/passwd)
SESSION=""
for f in /usr/share/wayland-sessions/*bigscreen*.desktop; do
	if [ -f "$f" ]; then
		SESSION="${f##*/}"
	fi
done
if [ -n "$USER" ] && [ -n "$SESSION" ]; then
	mkdir -p /etc/sddm.conf.d
	cat >/etc/plasmalogin.conf.d/autologin.conf <<EOF
[Autologin]
User=$USER
Session=$SESSION
EOF
fi

plasma-apply-wallpaperimage /home/$USER/.local/share/wallpapers/jr-korpa-E2i7Hftb_rI-unsplash.jpg

systemctl disable firstboot-autologin.service
