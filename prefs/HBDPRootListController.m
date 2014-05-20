#import "Global.h"
#import "HBDPRootListController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#include <notify.h>

static NSString *const kHBDPUpdateNowIdentifier = @"UpdateNow";

@implementation HBDPRootListController

#pragma mark - Constants

+ (NSString *)hb_shareText {
	return [NSString stringWithFormat:@"I’m using DailyPaper to enjoy a different wallpaper on my %@ every day!", [UIDevice currentDevice].localizedModel];
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://hbang.ws/dailypaper"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:215.f / 255.f green:170.f / 255.f blue:0 alpha:1];
}

#pragma mark - UIViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(wallpaperDidUpdate:) name:HBDPWallpaperDidUpdateNotification object:nil];
	}

	return self;
}

#pragma mark - Callbacks

- (void)forceUpdate:(PSSpecifier *)sender {
	notify_post("ws.hbang.dailypaper/ForceUpdate");

	PSTableCell *cell = (PSTableCell *)[self.view cellForRowAtIndexPath:[self indexPathForSpecifier:sender]];
	cell.cellEnabled = NO;
}

- (void)wallpaperDidUpdate:(NSNotification *)notification {
	PSTableCell *cell = (PSTableCell *)[self.view cellForRowAtIndexPath:[self indexPathForSpecifier:[self specifierForID:kHBDPUpdateNowIdentifier]]]; // ...why.
	cell.cellEnabled = YES;

	NSError *error = notification.userInfo[kHBDPErrorKey];

	if (error) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Couldn’t update your wallpaper because an error occurred." message:[NSString stringWithFormat:@"%@\nMake sure you’re connected to the Internet and try again in a few minutes.", notification.userInfo[kHBDPErrorKey]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alertView performSelector:@selector(show) withObject:nil afterDelay:0.1];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
