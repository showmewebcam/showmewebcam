#!/bin/bash

set -e

GENIMAGE_CFG="$(dirname $0)/genimage-${BOARDNAME}.cfg"
GENIMAGE_TMP="${BUILD_DIR}/genimage.tmp"

for arg in "$@"
do
	case "${arg}" in
		--add-miniuart-bt-overlay)
		if ! grep -qE '^dtoverlay=' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			echo "Adding 'dtoverlay=miniuart-bt' to config.txt (fixes ttyAMA0 serial console)."
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# fixes rpi (3B, 3B+, 3A+, 4B and Zero W) ttyAMA0 serial console
dtoverlay=miniuart-bt
__EOF__
		fi
		;;
		--aarch64)
		# Run a 64bits kernel (armv8)
		sed -e '/^kernel=/s,=.*,=Image,' -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		if ! grep -qE '^arm_64bit=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"

# enable 64bits support
arm_64bit=1
__EOF__
		fi
		;;
		--gpu_mem_256=*|--gpu_mem_512=*|--gpu_mem_1024=*)
		# Set GPU memory
		gpu_mem="${arg:2}"
		sed -e "/^${gpu_mem%=*}=/s,=.*,=${gpu_mem##*=}," -i "${BINARIES_DIR}/rpi-firmware/config.txt"
		;;
		--configure-picam)
		# Configure picam
		if ! grep -qE '^dtoverlay=dwc2' "${BINARIES_DIR}/rpi-firmware/config.txt"; then

			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"
dtoverlay=dwc2
__EOF__
		fi

		# Configure uart on 40-pin header
		if ! grep -qE '^enable_uart=1' "${BINARIES_DIR}/rpi-firmware/config.txt"; then

			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"
enable_uart=1
__EOF__
		fi

		# Set the bootloader delay to 0 seconds
		if ! grep -qE '^boot_delay=0' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"
boot_delay=0
__EOF__
		fi

		# Set turbo mode for boot
		if ! grep -qE '^initial_turbo' "${BINARIES_DIR}/rpi-firmware/config.txt"; then
			cat << __EOF__ >> "${BINARIES_DIR}/rpi-firmware/config.txt"
initial_turbo=10
__EOF__
		fi

		# Inform the kernel about the filesystem and ro state
		if ! grep -qE 'rootfstype=squashfs ro' "${BINARIES_DIR}/rpi-firmware/cmdline.txt"; then
			sed '/^root=/ s/$/ rootfstype=squashfs ro/' -i "${BINARIES_DIR}/rpi-firmware/cmdline.txt"
		fi

		if ! grep -qE 'modules-load=dwc2,libcomposite' "${BINARIES_DIR}/rpi-firmware/cmdline.txt"; then
			sed '/^root=/ s/$/ modules-load=dwc2,libcomposite/' -i "${BINARIES_DIR}/rpi-firmware/cmdline.txt"
		fi

		# Suppress kernel output during boot
		if ! grep -qE 'quiet' "${BINARIES_DIR}/rpi-firmware/cmdline.txt"; then
			sed '/^root=/ s/$/ quiet/' -i "${BINARIES_DIR}/rpi-firmware/cmdline.txt"
		fi

		# Add default camera.txt and add custom config if it exists
		cp "$BR2_EXTERNAL_PICAM_PATH/package/piwebcam/camera.txt" "${BINARIES_DIR}/camera.txt"
		if [ -f "$BR2_EXTERNAL_PICAM_PATH/camera.txt" ]; then
			cat << __EOF__ >> "${BINARIES_DIR}/camera.txt"

# User settings added during build

__EOF__
			cat "$BR2_EXTERNAL_PICAM_PATH/camera.txt" >> "${BINARIES_DIR}/camera.txt"
		fi

		# Add default enable-serial-debug file
		cat << __EOF__ >> "${BINARIES_DIR}/enable-serial-debug"
# This file signifies that you want to enable the serial debug console
# via the USB port. Once you have configured the webcam to your needs
# it is recommended that you delete this file. This action ensures that
# your webcam's firmware won't be changed by the host computer's software.
#
# In the future, we will not place this file here by default, instead you'll
# have to manually create this file if you want to access the console.
__EOF__

		;;
	esac

done

# Pass an empty rootpath. genimage makes a full copy of the given rootpath to
# ${GENIMAGE_TMP}/root so passing TARGET_DIR would be a waste of time and disk
# space. We don't rely on genimage to build the rootfs image, just to insert a
# pre-built one in the disk image.

trap 'rm -rf "${ROOTPATH_TMP}"' EXIT
ROOTPATH_TMP="$(mktemp -d)"

rm -rf "${GENIMAGE_TMP}"

genimage \
	--rootpath "${ROOTPATH_TMP}"   \
	--tmppath "${GENIMAGE_TMP}"    \
	--inputpath "${BINARIES_DIR}"  \
	--outputpath "${BINARIES_DIR}" \
	--config "${GENIMAGE_CFG}"

exit $?
