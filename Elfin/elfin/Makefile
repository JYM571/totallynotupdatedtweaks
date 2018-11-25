ARCHS = arm64
TARGET = iphone:clang:9.2:latest

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Elfin
Elfin_FILES = $(wildcard *.xm Files/*.m)
Elfin_PRIVATE_FRAMEWORKS = MediaRemote MediaPlayer

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
