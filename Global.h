#import <UIKit/UIKit.h>
#include <sys/cdefs.h>
#include <substrate.h> // what.
#include <notify.h>

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
static NSString *const HBDPWallpaperDidSaveNotification = @"HBDPWallpaperDidSaveNotification";

static NSString *const kHBDPErrorKey = @"error";

static NSString *const kHBDPPrefsPath = @"/var/mobile/Library/Preferences/ws.hbang.dailypaper.plist";
static NSString *const kHBDPMetadataPath = @"/var/mobile/Library/Caches/ws.hbang.dailypaper.plist";

static NSString *const kHBDPEnabledKey = @"Enabled";
static NSString *const kHBDPUseWiFiOnlyKey = @"WiFiOnly";
static NSString *const kHBDPUseRetinaKey = @"Retina";
static NSString *const kHBDPRegionKey = @"Region";
static NSString *const kHBDPWallpaperModeKey = @"WallpaperMode";

static NSString *const kHBDPDescriptionKey = @"Description";
static NSString *const kHBDPURLKey = @"URL";

#define GET_BOOL(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).boolValue : default)
#define GET_FLOAT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).floatValue : default)
#define GET_INT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).intValue : default)

#ifndef DAILYPAPER_GLOBAL_M
__BEGIN_DECLS

NSString *HBDPBingRegionToMarket(HBDPBingRegion region);
NSTimeZone *HBDPBingRegionToTimezone(HBDPBingRegion region);

__END_DECLS
#endif
