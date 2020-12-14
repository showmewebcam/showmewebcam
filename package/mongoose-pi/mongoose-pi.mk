################################################################################
#
# mongoose
#
################################################################################

MONGOOSE_PI_VERSION = 7.0
MONGOOSE_PI_SITE = $(call github,cesanta,mongoose,$(MONGOOSE_PI_VERSION))
MONGOOSE_PI_LICENSE = GPL-2.0
MONGOOSE_PI_LICENSE_FILES = LICENSE
MONGOOSE_PI_INSTALL_STAGING = YES
# static library
MONGOOSE_PI_INSTALL_TARGET = NO

MONGOOSE_PI_CFLAGS = $(TARGET_CFLAGS)

ifeq ($(BR2_PACKAGE_OPENSSL),y)
MONGOOSE_PI_DEPENDENCIES += openssl
MONGOOSE_PI_CFLAGS += -DMG_ENABLE_SSL
endif

define MONGOOSE_PI_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CC) -c $(@D)/mongoose.c $(MONGOOSE_PI_CFLAGS) -o $(@D)/mongoose.o
	$(TARGET_MAKE_ENV) $(TARGET_AR) rcs $(@D)/libmongoose.a $(@D)/mongoose.o
endef

define MONGOOSE_PI_INSTALL_STAGING_CMDS
	$(INSTALL) -D -m 644 $(@D)/libmongoose.a \
		$(STAGING_DIR)/usr/lib/libmongoose.a
	$(INSTALL) -D -m 644 $(@D)/mongoose.h \
		$(STAGING_DIR)/usr/include/mongoose.h
endef

$(eval $(generic-package))
