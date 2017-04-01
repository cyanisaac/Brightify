# Makefile for Brightify, covering the standard tweak file.
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

CFLAGS = -Wno-unused-variable
Brightify_CFLAGS = -fobjc-arc
SYSROOT = $(THEOS)/sdks/iPhoneOS10.1.sdk

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Brightify
Brightify_FILES = Tweak.xm

BUNDLE_NAME = com.cyanisaac.brightify

com.cyanisaac.brightify_INSTALL_PATH = /Library/MobileSubstrate/DynamicLibraries

include $(THEOS)/makefiles/bundle.mk

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += brightifypreferencesbundle
include $(THEOS_MAKE_PATH)/aggregate.mk
