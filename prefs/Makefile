include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = DailyPaper
DailyPaper_FILES = $(wildcard *.m)
DailyPaper_INSTALL_PATH = /Library/PreferenceBundles
DailyPaper_FRAMEWORKS = UIKit
DailyPaper_PRIVATE_FRAMEWORKS = Preferences
DailyPaper_EXTRA_FRAMEWORKS = CepheiPrefs

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DailyPaper.plist$(ECHO_END)
