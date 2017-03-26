CFLAGS = -Wno-unused-variable
Whiteify_CFLAGS = -fobjc-arc

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Whiteify
Whiteify_FILES = Tweak.xm

BUNDLE_NAME = com.cyantycdev.whiteify

com.cyantycdev.whiteify_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
