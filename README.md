# pyGameOS
armbian + pyGame

A lightweight build of Armbian with Pygame-CE built in for SDL2 (no X-win bloat) display.

# Features
* 🐧 Debian 13 trixie based.
* ❤️ Built with Armbian userpatches framework.

# Requirements for building ARMBIAN image
* 8GB RAM
* 10GB Disk
* 3-5GB Download
* Hour or Two

# Using this repo
To get a image to flash to SDcard follow these directions. I use a Ubuntu 26.04 Virtual Image to follow the steps below.

Checkout armbian/build and enter the dir

```
git clone https://github.com/armbian/build.git
cd build
```

Checkout this repo as "userpatches"

`git clone https://github.com/SpudGunMan/pyGameOs userpatches`

Compile!

`./userpatches/run-build.sh build`

* Typically you dont need to change any kernel options (skip)
* rpi4b is the generic board for all most all raspberry
* Console interface (server)
* Minimal Image with Console

The output image will go into .. build/output/images

# Using the pyGameOS
* Flash the latest image from the build tool, using balenaEtcher or a similar tool.
* login with default credentials. You will be prompted to change this upon first login.
* `sudo armbian-config`
* Test display and pygame `python -m pygame.examples.aliens`
* install your pyGame project

Setting Time
* `sudo systemctl enable --now systemd-timesyncd.service`
* `sudo hostnamectl set-hostname <new-hostname>`
* `sudo timedatectl set-timezone Region/City`
* `sudo timedatectl set-ntp true`

# Customizing pyGameOS for deployment
* See [armbian documentation](https://docs.armbian.com/build-framework/)
* see [customize-image.sh](customize-image.sh)
