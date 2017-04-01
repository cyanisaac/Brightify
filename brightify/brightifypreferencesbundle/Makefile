# Makefile for Brightify Preferences, subproject for Brightify for preference
# bundle with applicable options/killswitch
# Copyright (c) 2017 Isaac Trimble-Pederson, All Rights Reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

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
