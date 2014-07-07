include theos/makefiles/common.mk

TWEAK_NAME = DailyPaper
DailyPaper_FILES = Tweak.xm NCHax.x
DailyPaper_FRAMEWORKS = UIKit
DailyPaper_PRIVATE_FRAMEWORKS = PersistentConnection PhotoLibrary SpringBoardFoundation

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs weeapp
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences; sleep 0.2; sbopenurl 'prefs:root=Tweaks&path=DailyPaper'"
else
	install.exec spring
endif
