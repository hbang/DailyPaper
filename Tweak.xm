#import "Global.h"
#include <substrate.h> // what.
#include <notify.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <PersistentConnection/PCPersistentTimer.h>
#import <PhotoLibrary/PLStaticWallpaperImageViewController.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBWiFiManager.h>
#import <SpringBoardFoundation/SBFWallpaperParallaxSettings.h>

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

static NSString *const HBDPErrorDomain = @"HBDPErrorDomain";

BOOL enabled, useRetina, useWiFiOnly;
HBDPBingRegion region;
PLWallpaperMode wallpaperMode;

BOOL isRunning, isWaitingForWiFi, isFirstRun;

@interface SpringBoard (DailyPaper)

- (void)_dailypaper_configureTimer;
- (void)_dailypaper_updateWallpaper;

@end

#pragma mark - Region to market/timezone

NSString *HBDPBingRegionToMarket(HBDPBingRegion region) {
	switch (region) {
		case HBDPBingRegionWorldwide:
		default:
			return @"en-ww";
			break;

		case HBDPBingRegionAustralia:
			return @"en-au";
			break;

		case HBDPBingRegionCanada:
			return @"en-ca";
			break;

		case HBDPBingRegionChina:
			return @"zh-cn";
			break;

		case HBDPBingRegionFrance:
			return @"fr-fr";
			break;

		case HBDPBingRegionGermany:
			return @"de-de";
			break;

		case HBDPBingRegionJapan:
			return @"ja-jp";
			break;

		case HBDPBingRegionUnitedKingdom:
			return @"en-gb";
			break;

		case HBDPBingRegionUnitedStates:
			return @"en-us";
			break;
	}
}

NSTimeZone *HBDPBingRegionToTimezone(HBDPBingRegion region) {
	switch (region) {
		case HBDPBingRegionWorldwide:
		case HBDPBingRegionUnitedStates:
		default:
			return [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
			break;

		case HBDPBingRegionAustralia:
			return [NSTimeZone timeZoneWithName:@"Australia/Sydney"];
			break;

		case HBDPBingRegionCanada:
			return [NSTimeZone timeZoneWithName:@"Canada/Eastern"];
			break;

		case HBDPBingRegionChina:
			return [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
			break;

		case HBDPBingRegionFrance:
			return [NSTimeZone timeZoneWithName:@"Europe/Paris"];
			break;

		case HBDPBingRegionGermany:
			return [NSTimeZone timeZoneWithName:@"Europe/Berlin"];
			break;

		case HBDPBingRegionJapan:
			return [NSTimeZone timeZoneWithName:@"Asia/Tokyo"];
			break;

		case HBDPBingRegionUnitedKingdom:
			return [NSTimeZone timeZoneWithName:@"Europe/London"];
			break;
	}
}

void HBDPUpdateWallpaper(void(^completion)(NSError *error), BOOL onDemand) {
	if (isRunning) {
		completion([NSError errorWithDomain:HBDPErrorDomain code:2 userInfo:@{ NSLocalizedDescriptionKey: @"A wallpaper update is already running." }]);
		return;
	}

	[(SpringBoard *)[UIApplication sharedApplication] _dailypaper_configureTimer];

	if (!onDemand) {
		if (!enabled) {
			completion([NSError errorWithDomain:HBDPErrorDomain code:1 userInfo:@{ NSLocalizedDescriptionKey: @"Wallpaper updating is disabled." }]);
			return;
		}

		if (useWiFiOnly) {
			BOOL failed = NO;

			if (isWaitingForWiFi) {
				failed = YES;
			} else if (((SBWiFiManager *)[%c(SBWiFiManager) sharedInstance]).signalStrengthBars < 2) {
				failed = YES;
				isWaitingForWiFi = YES;
			}

			if (failed) {
				completion([NSError errorWithDomain:HBDPErrorDomain code:3 userInfo:@{ NSLocalizedDescriptionKey: @"Wallpaper updating is waiting for a Wi-Fi connection." }]);
				return;
			}
		}
	}

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		isRunning = YES;

		CGSize screenSize = [SBFWallpaperParallaxSettings minimumWallpaperSizeForCurrentDevice];

		if (useRetina && [UIScreen mainScreen].scale > 1.f) {
			screenSize.width *= [UIScreen mainScreen].scale;
			screenSize.height *= [UIScreen mainScreen].scale;
		}

		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.bing.com/ImageResolution.aspx?w=%li&h=%li&mkt=%@", (long)screenSize.width, (long)screenSize.height, HBDPBingRegionToMarket(region)]];
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:&error];

		if (error) {
			completion(error);
			isRunning = NO;
			return;
		}

		PLStaticWallpaperImageViewController *wallpaperViewController = [[[PLStaticWallpaperImageViewController alloc] initWithUIImage:[UIImage imageWithData:data]] autorelease];
		wallpaperViewController.saveWallpaperData = YES;

		uintptr_t address = (uintptr_t)&wallpaperMode;
		object_setInstanceVariable(wallpaperViewController, "_wallpaperMode", *(PLWallpaperMode **)address);

		[wallpaperViewController _savePhoto];

		isRunning = NO;

		completion(nil);
	});
}

void HBDPUpdateWallpaperOnDemand() {
	HBDPUpdateWallpaper(^(NSError *error) {
		NSLog(@"dailypaper: wallpaper update error: %@", error);

		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:HBDPWallpaperDidUpdateNotification object:nil userInfo:error ? @{ kHBDPErrorKey: error.localizedDescription } : nil];
	}, YES);
}

#pragma mark - Scheduling

%hook SpringBoard

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	%orig;
	[self _dailypaper_configureTimer];
}

%new - (void)_dailypaper_configureTimer {
	NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
	calendar.timeZone = HBDPBingRegionToTimezone(region);

	NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:[NSDate date]];
	dateComponents.day++;
	dateComponents.hour = 0;
	dateComponents.minute = arc4random_uniform(3); // let's not ddos bing
	dateComponents.second = arc4random_uniform(61);
	NSLog(@"dailypaper: scheduling next update for %@", [calendar dateFromComponents:dateComponents]);

	PCPersistentTimer *timer = [[[PCPersistentTimer alloc] initWithFireDate:[calendar dateFromComponents:dateComponents] serviceIdentifier:@"ws.hbang.dailypaper" target:self selector:@selector(_dailypaper_updateWallpaper) userInfo:nil] autorelease];
	[timer scheduleInRunLoop:[NSRunLoop mainRunLoop]];
}

%new - (void)_dailypaper_updateWallpaper {
	NSLog(@"dailypaper: update!");

	HBDPUpdateWallpaper(^(NSError *error) {
		NSLog(@"dailypaper: wallpaper update error: %@", error);
	}, NO);
}

%end

#pragma mark - Wi-Fi postponing

/*
 probably a lazy hack. i'm sure there has to be something
 in PersistentConnection for this
*/

%hook SBWiFiManager

- (void)_updateWiFiState {
	%orig;

	if (isWaitingForWiFi && self.signalStrengthBars > 1) {
		isWaitingForWiFi = NO;
		[(SpringBoard *)[UIApplication sharedApplication] _dailypaper_updateWallpaper];
	}
}

%end

#pragma mark - First run

%group FirstRun

%hook SBLockScreenManager

- (void)_finishUIUnlockFromSource:(NSInteger)source withOptions:(NSDictionary *)options {
	%orig;

	if (isFirstRun) {
		isFirstRun = NO;

		NSURL *url;

		if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/PreferenceOrganizer2.dylib"]) {
			// this is broken... https://github.com/angelXwind/PreferenceOrganizer2/issues/3
			url = [NSURL URLWithString:@"prefs:root=Tweaks&path=DailyPaper"];
		} else {
			url = [NSURL URLWithString:@"prefs:root=DailyPaper"];
		}

		[[UIApplication sharedApplication] openURL:url];
	}
}

%end

%end

#pragma mark - Preferences

static NSString *const kHBDPPrefsPath = @"/var/mobile/Library/Preferences/ws.hbang.dailypaper.plist";

static NSString *const kHBDPEnabledKey = @"Enabled";
static NSString *const kHBDPUseWiFiOnlyKey = @"WiFiOnly";
static NSString *const kHBDPUseRetinaKey = @"Retina";
static NSString *const kHBDPRegionKey = @"Region";
static NSString *const kHBDPWallpaperModeKey = @"WallpaperMode";

void HBDPLoadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kHBDPPrefsPath];

	enabled = GET_BOOL(kHBDPEnabledKey, YES);
	useWiFiOnly = GET_BOOL(kHBDPUseWiFiOnlyKey, NO);
	useRetina = GET_BOOL(kHBDPUseRetinaKey, !IS_IPAD);
	region = GET_INT(kHBDPRegionKey, HBDPBingRegionWorldwide);
	wallpaperMode = GET_INT(kHBDPWallpaperModeKey, PLWallpaperModeBoth);

	if (!prefs) {
		isFirstRun = YES;
		%init(FirstRun);

		[@{} writeToFile:kHBDPPrefsPath atomically:YES];
	}
}

%ctor {
	%init;
	HBDPLoadPrefs();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBDPLoadPrefs, CFSTR("ws.hbang.dailypaper/ReloadPrefs"), NULL, kNilOptions);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBDPUpdateWallpaperOnDemand, CFSTR("ws.hbang.dailypaper/ForceUpdate"), NULL, kNilOptions);
}
