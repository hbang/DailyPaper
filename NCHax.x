#import <BulletinBoard/BBSectionInfo.h>
#import <UIKit/UIImage+Private.h>

// courtesy of benno

BOOL isDailyPaper = NO;

%hook SBBulletinObserverViewController

- (void)_addSection:(BBSectionInfo *)section toCategory:(NSInteger)category widget:(id)widget {
	if ([section.sectionID isEqualToString:@"ws.hbang.dailypaperweeapp"]) {
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
