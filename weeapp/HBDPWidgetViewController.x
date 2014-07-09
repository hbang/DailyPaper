#import "Global.h"
#import "HBDPWidgetViewController.h"
#import "HBDPXMLParserHell.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBTodayBulletinCell.h>

static CGFloat const kHBDPWidgetViewControllerHorizontalMargin = 10.f;

HBDPBingRegion region;

@implementation HBDPWidgetViewController {
	UIButton *_copyrightButton;
	NSURL *_copyrightURL;
	BOOL _isStale;
	BOOL _isLoading;
}

#pragma mark - Constants

- (CGSize)preferredViewSize {
	return CGSizeMake(0, (kHBDPWidgetViewControllerHorizontalMargin * 2) + ([@"X" sizeWithAttributes:[%c(SBTodayBulletinCell) defaultTextAttributes]].height * 6));
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

	_isStale = YES;
	_isLoading = NO;

	_copyrightButton = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
	_copyrightButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	_copyrightButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_copyrightButton.titleLabel.numberOfLines = 6;
	_copyrightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	_copyrightButton.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
	_copyrightButton.contentEdgeInsets = UIEdgeInsetsMake(kHBDPWidgetViewControllerHorizontalMargin, 48.f, kHBDPWidgetViewControllerHorizontalMargin, 15.f);
	_copyrightButton.userInteractionEnabled = NO;
	[_copyrightButton addTarget:self action:@selector(copyrightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_copyrightButton];

	self.buttonLabel = @"Loading…";

	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(wallpaperDidUpdate:) name:HBDPWallpaperDidUpdateNotification object:nil];
}

- (NSString *)buttonLabel {
	return [_copyrightButton attributedTitleForState:UIControlStateNormal].string;
}

- (void)setButtonLabel:(NSString *)buttonLabel {
	[_copyrightButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:buttonLabel attributes:[%c(SBTodayBulletinCell) defaultTextAttributes]] autorelease] forState:UIControlStateNormal];
}

- (void)hostDidPresent {
	[super hostDidPresent];

	if (_isStale && !_isLoading) {
		_isStale = NO;
		_isLoading = YES;

		HBDPXMLParserHell *parser = [[HBDPXMLParserHell alloc] init];
		[parser loadWithBingMarket:HBDPBingRegionToMarket(region) completion:^(NSString *copyright, NSURL *url, NSError *error) {
			[_copyrightURL release];
			[parser release];

			if (error) {
				NSLog(@"dailypaper: failed to load details: %@", error);

				self.buttonLabel = @"Couldn’t load the wallpaper details.";
				_copyrightButton.userInteractionEnabled = NO;
				_isStale = YES;
			} else {
				self.buttonLabel = copyright;
				_copyrightURL = [url copy] ?: [[NSURL alloc] initWithString:@"https://www.bing.com"];
			}

			_isLoading = NO;
		}];
	}
}

#pragma mark - Actions

- (void)copyrightButtonTapped {
	if (_copyrightURL) {
		[[UIApplication sharedApplication] openURL:_copyrightURL];
	}
}

- (void)wallpaperDidUpdate:(NSNotification *)notification {
	_isStale = YES;
}

#pragma mark - Memory management

- (void)dealloc {
	[_copyrightButton release];
	[_copyrightURL release];

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end

#pragma mark - Preferences

void HBDPLoadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:kHBDPPrefsPath];
	region = GET_INT(kHBDPRegionKey, HBDPBingRegionWorldwide);
}

%ctor {
	%init;
	HBDPLoadPrefs();

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBDPLoadPrefs, CFSTR("ws.hbang.dailypaper/ReloadPrefs"), NULL, kNilOptions);
}
