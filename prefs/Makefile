include theos/makefiles/common.mk

BUNDLE_NAME = DontForget
DontForget_FILES = DontForget.mm
DontForget_INSTALL_PATH = /Library/PreferenceBundles
DontForget_FRAMEWORKS = UIKit
DontForget_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DontForget.plist$(ECHO_END)
