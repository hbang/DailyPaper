#import <UIKit/UIKit.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <UIKit/UIImage+Private.h>

static NSString *const kHBDPWeeAppIdentifier = @"ws.hbang.dailypaperweeapp";

#pragma mark - Change section header and icon

// courtesy of benno

BOOL isDailyPaper = NO;

%hook SBBulletinObserverViewController

- (void)_addSection:(BBSectionInfo *)section toCategory:(NSInteger)category widget:(id)widget {
	if ([section.sectionID isEqualToString:kHBDPWeeAppIdentifier]) {
		isDailyPaper = YES;
		%orig;
		isDailyPaper = NO;
	} else {
		%orig;
	}
}

%end

%hook SBBulletinListSection

- (void)setDisplayName:(NSString *)displayName {
	%orig(isDailyPaper ? @"Current Wallpaper" : displayName);
}

- (void)setIconImage:(UIImage *)iconImage {
	%orig(isDailyPaper ? [UIImage imageNamed:@"icon" inBundle:[NSBundle bundleWithPath:@"/Library/PreferenceBundles/DailyPaper.bundle"]] : iconImage);
}

%end

#pragma mark - Enable by default

%hook SBNotificationCenterDataProviderController

- (NSArray *)_copyDefaultEnabledWidgetIDs {
	NSArray *defaultWidgets = %orig;
	return [[defaultWidgets arrayByAddingObject:kHBDPWeeAppIdentifier] copy];
}

%end
