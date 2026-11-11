#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4

# 'Global' env vars for all functions in this script
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

# Release-specific variables
case $RELEASE in
	trixie)
		pipx_g=true
		;;
	bookworm)
		pipx_g=false
		;;
	resolute)
		pipx_g=true
		;;
	noble)
		pipx_g=false
		;;
	*)
		# Exit early for unsupported releases
		echo "Unsupported RELEASE: $RELEASE"
		exit 1
		;;
esac

Main() {
	apt-get update

	# Added packages for dev-kit in runtime
	InstallAptPkg "git"
	InstallAptPkg "python3"
	InstallAptPkg "python3-venv"
	InstallAptPkg "python3-pip"
	InstallAptPkg "python3-dev"
	InstallAptPkg "python3-setuptools"
	InstallAptPkg "python-is-python3"
	InstallAptPkg "build-essential"
	InstallAptPkg "pkg-config"
	InstallAptPkg "rustc"
	InstallAptPkg "cargo"
	InstallAptPkg "libffi-dev"
	InstallAptPkg "libssl-dev"

    # Graphics libraries for display and rendering
	# Core DRM and buffer management (required for embedded graphics)
	InstallAptPkg "libdrm-dev"
	InstallAptPkg "libgbm-dev"
	
	# OpenGL/Graphics rendering libraries
	InstallAptPkg "libegl1-mesa-dev"
    InstallAptPkg "libgles2-mesa-dev"
    InstallAptPkg "python3-opengl"
    
	# SDL2 multimedia framework
	InstallAptPkg "libsdl2-dev"
	InstallAptPkg "libsdl2-image-dev"
	InstallAptPkg "libsdl2-mixer-dev"
	InstallAptPkg "libsdl2-ttf-dev"
	InstallAptPkg "libsdl2-gfx-dev"
	
	# Font and image support
	InstallAptPkg "libfontconfig"
	InstallAptPkg "libfreetype6-dev"
    InstallAptPkg "libjpeg-dev"
    InstallAptPkg "libpng-dev"

	# Input handling and audio
    InstallAptPkg "libxkbcommon-dev"
    InstallAptPkg "libportmidi-dev"
    
	# Optional: KMS/DRM diagnostic tool
    #InstallAptPkg "kmscube"

    # PyGame-CE
	InstallPipPkg "pygame-ce"

	#Example Project Loaded
	GitClone "https://github.com/SpudGunMan/pytide" "/opt/pytide"
	GitClone "https://github.com/SpudGunMan/EQMap2" "/opt/EQMap2"

	# Always run
	ApplyFSOverlay
	BoardSpecific "$@"
	apt-get clean && rm -rf /var/lib/apt/lists/*
	CompileDTBO
} # Main

ApplyFSOverlay() {
	# Copy overlay files to their destinations
	# replacing existing files
	cp -r /tmp/overlay/fs/* /
} # ApplyFSOverlay

InstallAptPkg() {
	PKGSPEC="$1"
	# Install package via apt-get
	echo "APT: Installing ${PKGSPEC}..."
	apt-get --yes --allow-unauthenticated \
		install $PKGSPEC
} # InstallAptPkg

InstallPipxPkg() {
	PKGSPEC="$1"
	# Install package via 'pipx install --global'
	echo "PIPX: Installing ${PKGSPEC}..."
	pipx install --global "${PKGSPEC}"
	# --global flag requires pipx 1.5.0 or newer
} # InstallPipxPkg

InstallPipPkg() {
	PKGSPEC="$1"
	echo "PIP: Installing ${PKGSPEC}..."
	# Install package via pip
	# Avoid uninstalling distro-managed Python packages (no RECORD metadata)
	pip install "${PKGSPEC}" --break-system-packages --ignore-installed
} # InstallPipPkg

GitClone() {
	REPO_URL="$1"
	DEST_DIR="$2"
	echo "GIT: Cloning ${REPO_URL}..."
	git clone --depth=1 "$REPO_URL" "$DEST_DIR"
} # GitClone

CompileDTBO() {
	# Always compile DTBOs for each family (even if not enabled by default)
	mkdir -p /boot/overlay-user
	echo "Compiling device tree overlays for ${LINUXFAMILY}"
	echo "located in overlay/dtbo/${LINUXFAMILY}"
	shopt -s nullglob
	# If *.dts returns no results, the loop will not execute (desired behavior)
	for f in /tmp/overlay/dtbo/"${LINUXFAMILY}"/*.dts; do
		DTBO_NAME=$(basename "${f}" .dts)
		echo "Compiling ${DTBO_NAME}"
		dtc -@ -q -I dts -O dtb -o "/boot/overlay-user/${DTBO_NAME}.dtbo" "${f}"
	done
	shopt -u nullglob
} # CompileDTBO

EnableUserDTOverlay() {
	USER_OVERLAYS="$1"
	echo "Enabling user_overlays: ${USER_OVERLAYS}"
	# Enable overlays (space separated)
	# in /boot/armbianEnv.txt
	if [ -f /boot/armbianEnv.txt ]; then
		if grep -q "user_overlays=" /boot/armbianEnv.txt; then
			# Append to existing user_overlays
			sed -i "s/user_overlays=\(.*\)/user_overlays=\1 ${USER_OVERLAYS}/" /boot/armbianEnv.txt
		else
			# Add new user_overlays line
			echo "user_overlays=${USER_OVERLAYS}" >> /boot/armbianEnv.txt
		fi
	else
		echo "Warning: /boot/armbianEnv.txt not found, cannot enable device tree overlays"
	fi
} # EnableUserDTOverlay

EnableKernelDTOverlay() {
	OVERLAY_NAME="$1"
	echo "Enabling kernel (builtin) overlay: ${OVERLAY_NAME}"
	# Enable overlay in /boot/armbianEnv.txt
	if [ -f /boot/armbianEnv.txt ]; then
		if grep -q "overlays=" /boot/armbianEnv.txt; then
			# Append to existing overlays
			sed -i "s/overlays=\(.*\)/overlays=\1 ${OVERLAY_NAME}/" /boot/armbianEnv.txt
		else
			# Add new overlays line
			echo "overlays=${OVERLAY_NAME}" >> /boot/armbianEnv.txt
		fi
	else
		echo "Warning: /boot/armbianEnv.txt not found, cannot enable device tree overlays"
	fi
} # EnableKernelDTOverlay

BoardSpecific() {
	# Note: Board specific customizations may also be added via Extensions
	# See extensions/ directory
	case $BOARD in
		rpi*|bcm*)
			echo "Raspberry Pi detected: $BOARD"
			# RPi-specific graphics optimizations could be added here
			;;
		nano*|opipc*)
			echo "Allwinner board detected: $BOARD"
			# Allwinner-specific graphics optimizations could be added here
			;;
		*)
			echo "No board-specific customizations for board: $BOARD"
			;;
	esac
} # BoardSpecific

Main "$@"