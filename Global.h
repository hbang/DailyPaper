#include <sys/cdefs.h>

typedef NS_ENUM(NSUInteger, HBDPBingRegion) {
	HBDPBingRegionWorldwide,
	HBDPBingRegionAustralia,
	HBDPBingRegionCanada,
	HBDPBingRegionChina,
	HBDPBingRegionFrance,
	HBDPBingRegionGermany,
	HBDPBingRegionJapan,
	HBDPBingRegionNewZealand,
	HBDPBingRegionUnitedKingdom,
	HBDPBingRegionUnitedStates
};

static NSString *const HBDPWallpaperDidUpdateNotification = @"HBDPWallpaperDidUpdateNotification";
static NSString *const HBDPWeeAppNeedsInformationNotification = @"HBDPWallpaperDidUpdateNotification";

static NSString *const kHBDPErrorKey = @"error";

static NSString *const kHBDPPrefsPath = @"/var/mobile/Library/Preferences/ws.hbang.dailypaper.plist";

static NSString *const kHBDPEnabledKey = @"Enabled";
static NSString *const kHBDPUseWiFiOnlyKey = @"WiFiOnly";
static NSString *const kHBDPUseRetinaKey = @"Retina";
static NSString *const kHBDPRegionKey = @"Region";
static NSString *const kHBDPWallpaperModeKey = @"WallpaperMode";

#ifndef DAILYPAPER_GLOBAL_M
__BEGIN_DECLS

NSString *HBDPBingRegionToMarket(HBDPBingRegion region);
NSTimeZone *HBDPBingRegionToTimezone(HBDPBingRegion region);

__END_DECLS
#endif
