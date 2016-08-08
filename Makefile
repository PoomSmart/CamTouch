DEBUG = 0
PACKAGE_VERSION = 1.1

ifeq ($(SIMULATOR),1)
	TARGET = simulator:clang:latest
	ARCHS = x86_64 i386
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamTouch
CamTouch_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

all::
ifeq ($(SIMULATOR),1)
	@cp -v $(PWD)/.theos/$(THEOS_OBJ_DIR_NAME)/*.dylib /opt/simject
	@cp -v $(PWD)/*.plist /opt/simject
endif