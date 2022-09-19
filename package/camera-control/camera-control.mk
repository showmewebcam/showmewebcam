################################################################################
#
# camera-control
#
################################################################################

CAMERA_CONTROL_VERSION = c50efb3c83be86a74fe64a72e0c2c231625138b6
CAMERA_CONTROL_SITE = https://github.com/peterbay/camera-control.git
CAMERA_CONTROL_LICENSE = GPL-3.0+
CAMERA_CONTROL_LICENSE_FILES = LICENSE
CAMERA_CONTROL_DEST_DIR = /opt/camera-control
CAMERA_CONTROL_SITE_METHOD = git
CAMERA_CONTROL_DEPENDENCIES = host-pkgconf ncurses

define CAMERA_CONTROL_BUILD_CMDS
	$(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" -C $(@D)
endef

define CAMERA_CONTROL_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(CAMERA_CONTROL_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/camera-ctl $(TARGET_DIR)$(CAMERA_CONTROL_DEST_DIR)
	$(INSTALL) -D -m 0755 $(CAMERA_CONTROL_PKGDIR)/camera-ctl $(TARGET_DIR)/usr/bin/camera-ctl
endef

$(eval $(generic-package))
