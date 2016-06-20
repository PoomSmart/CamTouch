GO_EASY_ON_ME = 1
DEBUG = 0
TARGET = iphone:latest:9.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = CamTouch
CamTouch_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

