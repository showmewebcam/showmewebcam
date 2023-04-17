################################################################################
#
# piwebcam
#
################################################################################

UVC_GADGET_VERSION = e1c738181746876a9b9ca75fd12b9d565ae75644
UVC_GADGET_SITE = https://gitlab.freedesktop.org/camera/uvc-gadget.git
UVC_GADGET_LICENSE = GPL-2.0+
UVC_GADGET_LICENSE_FILES = LICENSE
UVC_GADGET_SITE_METHOD = git

UVC_GADGET_DEPENDENCIES = host-pkgconf \
	libcamera

UVC_GADGET_CONF_OPTS = \
	-Dwerror=false

$(eval $(meson-package))
