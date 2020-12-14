#############################################################
#
# rpic-raspimjpeg
#
#############################################################
RPIC_RASPIMJPEG_VERSION = 9d2df858c10419b0274ef657f8acc947375b8e88
RPIC_RASPIMJPEG_SITE_METHOD = git
RPIC_RASPIMJPEG_REPO_URL = https://github.com/rpicopter/raspimjpeg.git
RPIC_RASPIMJPEG_SITE = $(call qstrip,$(RPIC_RASPIMJPEG_REPO_URL))
# RPIC_RASPIMJPEG_DEPENDENCIES = rpi-userland rpic-gpac
RPIC_RASPIMJPEG_DEPENDENCIES = rpi-userland 

RPIC_RASPIMJPEG_BCM_H = $(TARGET_DIR)/usr/include/interface/ 
RPIC_RASPIMJPEG_BCM_H = $(STAGING_DIR)/usr/include/interface/ 
RPIC_RASPIMJPEG_DEST_DIR = /opt/rpic-raspimjpeg
define RPIC_RASPIMJPEG_BUILD_CMDS
	$(MAKE) $(TARGET_CONFIGURE_OPTS) BCM_H_DIR=$(RPIC_RASPIMJPEG_BCM_H) -C $(@D) all
endef

define RPIC_RASPIMJPEG_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(RPIC_RASPIMJPEG_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/raspimjpeg $(TARGET_DIR)$(RPIC_RASPIMJPEG_DEST_DIR)
	$(INSTALL) -D -m 644 $(RPIC_RASPIMJPEG_PKGDIR)/config $(TARGET_DIR)$(RPIC_RASPIMJPEG_DEST_DIR)

endef

$(eval $(generic-package))