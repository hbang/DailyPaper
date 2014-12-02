#import "Global.h"
#import "HBDPRootListController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#include <notify.h>

static NSString *const kHBDPUpdateNowIdentifier = @"UpdateNow";
static NSString *const kHBDPSaveWallpaperIdentifier = @"SaveWallpaper";

@implementation HBDPRootListController

#pragma mark - Constants

+ (NSString *)hb_shareText {
	return [NSString stringWithFormat:@"I’m using DailyPaper to enjoy a different wallpaper on my %@ every day!", [UIDevice currentDevice].localizedModel];
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://hbang.ws/dailypaper"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:241.f / 255.f green:148.f / 255.f blue:0 alpha:1];
}

#pragma mark - UIViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(wallpaperDidUpdate:) name:HBDPWallpaperDidUpdateNotification object:nil];
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(wallpaperDidSave:) name:HBDPWallpaperDidSaveNotification object:nil];
	}

	return self;
}

#pragma mark - Actions

// TODO: this feels really ugly :(

- (void)forceUpdate:(PSSpecifier *)sender {
	[self _postNotification:CFSTR("ws.hbang.dailypaper/ForceUpdate") forSpecifier:sender];
}

- (void)saveWallpaper:(PSSpecifier *)sender {
	[self _postNotification:CFSTR("ws.hbang.dailypaper/SaveWallpaper") forSpecifier:sender];
}

- (void)_postNotification:(CFStringRef)notification forSpecifier:(PSSpecifier *)specifier {
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), notification, NULL, NULL, YES);

	PSTableCell *cell = (PSTableCell *)[(UITableView *)[self table] cellForRowAtIndexPath:[self indexPathForSpecifier:specifier]];
	cell.cellEnabled = NO;
}

#pragma mark - Callbacks

- (void)wallpaperDidUpdate:(NSNotification *)notification {
	[self _callbackReturnedWithError:notification.userInfo[kHBDPErrorKey] forIdentifier:kHBDPUpdateNowIdentifier];
}

- (void)wallpaperDidSave:(NSNotification *)notification {
	[self _callbackReturnedWithError:notification.userInfo[kHBDPErrorKey] forIdentifier:kHBDPSaveWallpaperIdentifier];
}

- (void)_callbackReturnedWithError:(NSError *)error forIdentifier:(NSString *)identifier {
	PSTableCell *cell = (PSTableCell *)[[self table] cellForRowAtIndexPath:[self indexPathForSpecifier:[self specifierForID:identifier]]]; // ...why.
	cell.cellEnabled = YES;

	if (error) {
		UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"Couldn’t download your wallpaper because an error occurred." message:[NSString stringWithFormat:@"%@\nMake sure you’re connected to the Internet and try again in a few minutes.", error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
		[alertView performSelector:@selector(show) withObject:nil afterDelay:0.1];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

@end
