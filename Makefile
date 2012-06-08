include theos/makefiles/common.mk

TWEAK_NAME = DontForget
DontForget_FILES = Tweak.xm
DontForget_FRAMEWORKS = UIKit AudioToolbox
DontForget_PRIVATE_FRAMEWORKS = CoreTelephony

SUBPROJECTS = prefs

include $(THEOS_MAKE_PATH)/aggregate.mk
include $(THEOS_MAKE_PATH)/tweak.mk
