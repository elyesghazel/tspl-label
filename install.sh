#!/usr/bin/env bash
# Install label + label-remote to ~/.local/bin and the udev rule (needs sudo).
set -euo pipefail
cd "$(dirname "$0")"

python3 -c 'import PIL' 2>/dev/null || { echo "missing Pillow: install python-pillow / python3-pil" >&2; exit 1; }
command -v pdftoppm >/dev/null || { echo "missing pdftoppm: install poppler / poppler-utils" >&2; exit 1; }

mkdir -p ~/.local/bin
install -m 755 label label-remote ~/.local/bin/
echo "installed label, label-remote -> ~/.local/bin"

sudo install -m 644 70-tspl-label.rules /etc/udev/rules.d/
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=usbmisc
echo "udev rule installed - replug the printer if 'label --check' still fails"
