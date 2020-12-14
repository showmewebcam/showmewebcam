################################################################################
#
# WebUi camera-control
#
################################################################################

PICAM_WEB_VERSION = b67662993514348ed82aa4bfa65994a9560ca89d
PICAM_WEB_SITE = git://github.com/tuyenld/picam-web.git
PICAM_WEB_LICENSE = GPL-3.0+
PICAM_WEB_LICENSE_FILES = LICENSE
PICAM_WEB_DEST_DIR = /opt/picam-web
PICAM_WEB_SITE_METHOD = git

define PICAM_WEB_BUILD_CMDS
	$(MAKE) CXX="$(TARGET_CXX)" \
	CFLAGS="-I$(STAGING_DIR)/usr/include/" \
	LIBS="-L$(STAGING_DIR)/usr/lib/" \
	CC="$(TARGET_CC)" \
	LD="$(TARGET_LD)" PKG_CONFIG="$(PKG_CONFIG_HOST_BINARY)" -C $(@D)
endef


define PICAM_WEB_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(PICAM_WEB_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/picam-web $(TARGET_DIR)$(PICAM_WEB_DEST_DIR)
	$(INSTALL) -D -m 0755 $(PICAM_WEB_PKGDIR)/picam-web.sh $(TARGET_DIR)$(PICAM_WEB_DEST_DIR)
	cp -r $(@D)/web_root $(TARGET_DIR)$(PICAM_WEB_DEST_DIR)/
endef

$(eval $(generic-package))
