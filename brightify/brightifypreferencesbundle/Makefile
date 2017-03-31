include $(THEOS)/makefiles/common.mk

SYSROOT = $(THEOS)/sdks/iPhoneOS9.3.sdk

BUNDLE_NAME = BrightifyPreferencesBundle
BrightifyPreferencesBundle_FILES = BTFYRootListController.m
BrightifyPreferencesBundle_INSTALL_PATH = /Library/PreferenceBundles
BrightifyPreferencesBundle_FRAMEWORKS = UIKit
BrightifyPreferencesBundle_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/BrightifyPreferencesBundle.plist$(ECHO_END)
