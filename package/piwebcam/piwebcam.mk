################################################################################
#
# piwebcam
#
################################################################################

PIWEBCAM_VERSION = f120aff082a03526c1327bd95f4136f08943758d
PIWEBCAM_SITE = git://github.com/showmewebcam/uvc-gadget.git
PIWEBCAM_LICENSE = GPL-2.0+
PIWEBCAM_LICENSE_FILES = LICENSE
PIWEBCAM_DEST_DIR = /opt/uvc-webcam
PIWEBCAM_SITE_METHOD = git
PIWEBCAM_INIT_SYSTEMD_TARGET = basic.target.wants

define PIWEBCAM_BUILD_CMDS
	$(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define PIWEBCAM_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/uvc-gadget $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/multi-gadget.sh $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/start-webcam.sh $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
endef

define PIWEBCAM_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/$(PIWEBCAM_INIT_SYSTEMD_TARGET)
	$(INSTALL) -D -m 644 $(@D)/piwebcam.service $(TARGET_DIR)/usr/lib/systemd/system
	ln -sf /usr/lib/systemd/system/piwebcam.service $(TARGET_DIR)/etc/systemd/system/$(PIWEBCAM_INIT_SYSTEMD_TARGET)
endef

$(eval $(generic-package))
