################################################################################
#
# soft-hwclock
#
################################################################################

SOFT_HWCLOCK_VERSION = aeaea431fb9d17005fefeeb34b80ea6fcc76adde
SOFT_HWCLOCK_SITE = git://github.com/kristjanvalur/soft-hwclock.git
SOFT_HWCLOCK_LICENSE = MIT
SOFT_HWCLOCK_LICENSE_FILES = LICENSE
SOFT_HWCLOCK_DEST_DIR = /opt/soft-hwclock
SOFT_HWCLOCK_SITE_METHOD = git

define SOFT_HWCLOCK_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)$(SOFT_HWCLOCK_DEST_DIR)
	$(INSTALL) -D -m 0755 $(@D)/soft-hwclock $(TARGET_DIR)$(SOFT_HWCLOCK_DEST_DIR)
endef

define SOFT_HWCLOCK_INSTALL_INIT_SYSTEMD
	mkdir -p $(TARGET_DIR)/etc/systemd/system/multi-user.target.wants
	for f in \
		soft-hwclock.service \
		soft-hwclock-tick.service \
		soft-hwclock-tick.timer; do \
		$(INSTALL) -D -m 644 $(@D)/$$f \
			$(TARGET_DIR)/usr/lib/systemd/system/$$f; \
		wanted_by="multi-user.target.wants"; \
		ln -sf /usr/lib/systemd/system/$$f \
			$(TARGET_DIR)/etc/systemd/system/$$wanted_by/$$f; \
	done
endef

$(eval $(generic-package))
