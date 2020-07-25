################################################################################
#
# piwebcam
#
################################################################################

PIWEBCAM_VERSION = 7f75011705c53c58e2faee9ef8bdc695fc389da8
PIWEBCAM_SITE = git://github.com/showmewebcam/uvc-gadget.git
PIWEBCAM_LICENSE = GPL-2.0+
PIWEBCAM_LICENSE_FILES = LICENSE
PIWEBCAM_DEST_DIR = /opt/uvc-webcam
PIWEBCAM_SITE_METHOD = git

define PIWEBCAM_BUILD_CMDS
	$(MAKE) CXX="$(TARGET_CXX)" CC="$(TARGET_CC)" LD="$(TARGET_LD)" -C $(@D)
endef

define PIWEBCAM_INSTALL_TARGET_CMDS
	mkdir $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/uvc-gadget $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/multi-gadget.sh $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/start-webcam.sh $(TARGET_DIR)$(PIWEBCAM_DEST_DIR)
endef

$(eval $(generic-package))
