# tspl-label

Print shipping labels, PDFs, images or plain text on a cheap USB thermal label printer from Linux, without the vendor app.

Many 4x6" label printers sold under random brands speak **TSPL**, a plain-text command language. Their Bluetooth apps (FlashLabel Pro and others) just send TSPL. Plugged in over USB, Linux exposes them as `/dev/usb/lp0`, and this tool writes TSPL straight to that device. No CUPS, no driver.

Tested on a **Y41BT** (USB id `5958:0041`, "YXWL"). Other TSPL printers should work too.

## Install

Needs Python 3 with Pillow, and `pdftoppm` (poppler).

```sh
# Arch
sudo pacman -S python-pillow poppler
# Debian / Ubuntu / Raspberry Pi OS
sudo apt install python3-pil poppler-utils

git clone https://github.com/elyesghazel/tspl-label
cd tspl-label
./install.sh        # copies label to ~/.local/bin, installs the udev rule (sudo)
```

Plug the printer in and check it:

```sh
label --check       # "printer ready"
```

If your printer has a different USB id, add it to `70-tspl-label.rules` before running `install.sh`. Find the id with `lsusb`, or with `journalctl -k | grep idVendor` right after plugging the printer in.

## Usage

```sh
label shipping-label.pdf          # one label per PDF page
label photo.png                   # image, auto-rotated, scaled and dithered
label -t "FRAGILE\nTHIS SIDE UP"  # big centred text
label -n 3 -t "KEEP"              # copies
label --preview file.pdf          # render to /tmp/label-preview-N.png, print nothing
label --size 60x80 file.pdf       # say which roll is loaded
```

### Label sizes

`--size` is the roll in the printer, `WIDTHxHEIGHT` in mm as the label comes out:

| Size | Dots (203 dpi) |
|------|----------------|
| `100x150` (4x6", default) | 800 x 1200 |
| `60x80` | 480 x 640 |

With `--size auto` (the default), a PDF picks the roll matching its page size. Landscape pages, such as Swiss Post WebStamp thermo labels (150x100 / 80x60), get rotated onto the roll. Files that need different rolls are refused, so print them in separate runs.

To add a size, add it to `ROLLS` at the top of `label`.

## Printing from another machine (optional)

`label-remote` lets another machine print here over SSH with a key that can do nothing else. Put this line in `~/.ssh/authorized_keys` on the machine with the printer:

```
command="/home/YOU/.local/bin/label-remote",restrict ssh-ed25519 AAAA... print-key
```

Then from the other machine:

```sh
ssh -i print-key you@printer-host check
ssh -i print-key you@printer-host "print auto" < label.pdf
```

Only `check` and `print <auto|100x150|60x80>` are accepted, and stdin has to be a PDF.

## Notes

- **Inverted or shifted output:** TSPL `BITMAP` uses 1 = white. If a different printer prints negatives, flip the bits in `tspl()`.
- **Narrow rolls** (like 60x80) on a 4" print head: the print position depends on where the printer's paper guides hold the roll. If labels come out shifted, add a `REFERENCE x,y` line to the TSPL header.
- **Status queries** (`~!T`, `ESC !?`) get no reply over USB on the Y41BT, so `--check` only tests that the device is there and writable.
- **Bluetooth:** the Y41BT also advertises BLE service `0x18F0` and likely accepts the same TSPL on characteristic `0x2AF1`. That path is untested here.

## License

MIT
