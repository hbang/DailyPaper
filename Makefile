TARGET = iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = DailyPaper
DailyPaper_FILES = $(wildcard *.m) Tweak.xm NCHax.x
DailyPaper_FRAMEWORKS = UIKit CoreGraphics
DailyPaper_PRIVATE_FRAMEWORKS = PersistentConnection PhotoLibrary SpringBoardFoundation
DailyPaper_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs weeapp
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
ifeq ($(RESPRING),0)
	install.exec "killall Preferences; sleep 0.2; sbopenurl 'prefs:root=DailyPaper'"
else
	install.exec spring
endif
