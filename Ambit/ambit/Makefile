ARCHS = arm64
TARGET = iphone:clang:9.2:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Ambit
Ambit_FILES = $(wildcard *.xm)

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
