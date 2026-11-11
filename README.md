# pyGameOS
armbian + pyGame = pyGameOS

A lightweight build of Armbian with Pygame-CE built in for SDL2 (no X-win bloat) display.

# Features
* 🐧 Debian 13 trixie based.
* ❤️ Built with Armbian userpatches framework.
* 👾 Pygame-CE pre-installed with SDL2 support
* 🍓 Raspberry Pi Support
* 🦾 Armbian [Supports](https://armbian.com/boards?support=community) over 400 SBC from 90 vendors!
* 💻 SDL (Simple DirectMedia Layer) acts as a universal abstraction layer for graphics, audio, and input. Because Pygame relies on SDL, code written for a lightweight Linux device (like a Raspberry Pi Zero or an embedded ARM board) can run natively without additional dependencies like X11

# Using pyGameOS
* Flash the latest image using balenaEtcher or a similar tool
* Log in with default credentials. You will be prompted to change them on first login
* Run `sudo armbian-config`
* Test the display and Pygame with `python -m pygame.examples.aliens`
* Install your Pygame project

## Setting Time and Hostname
* `sudo systemctl enable --now systemd-timesyncd.service`
* `sudo hostnamectl set-hostname <new-hostname>`
* `sudo timedatectl set-timezone Region/City`
* `sudo timedatectl set-ntp true`


# Using this repo for building pyGameOS image custom for your hardware

## Requirements of build machine
* ~8GB RAM, 10GB Disk, 3-5GB Download
* Hour or so of time

To create an image to flash to an SD card, follow these directions. This example uses Ubuntu 24.04 LTS (a virtual machine works fine).

Clone the Armbian build repository and enter the directory:

```
git clone https://github.com/armbian/build.git
cd build
```

Clone this repository as "userpatches":

```bash
git clone https://github.com/SpudGunMan/pyGameOS userpatches
```

Run the build script:

```bash
./userpatches/run-build.sh build
```

When prompted, choose these options:
* Skip kernel configuration (not needed for most use cases)
* `rpi4b` - the standard board option for most Raspberry Pi variants
* `Console interface (server)` - minimal server install
* `Minimal Image with Console` - lightweight footprint

The compiled image will be located in `build/output/images/`

## Customizing pyGameOS for deployment
* See [armbian documentation](https://docs.armbian.com/build-framework/)
* see [customize-image.sh](customize-image.sh)
