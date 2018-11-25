ARCHS = arm64
TARGET = iphone:clang:9.2:latest
THEOS_BUILD_DIR = debs
GO_EASY_ON_ME = 1

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Pascal
Pascal_FILES = $(wildcard *.xm *.m)
Pascal_FRAMEWORKS = AVFoundation CoreGraphics QuartzCore UIKit

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
include $(THEOS_MAKE_PATH)/aggregate.mk
