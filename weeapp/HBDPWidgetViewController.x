#import "Global.h"
#import "HBDPWidgetViewController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBTodayBulletinCell.h>

static CGFloat const kHBDPWidgetViewControllerHorizontalMargin = 10.f;

@implementation HBDPWidgetViewController {
	UIButton *_copyrightButton;
	NSURL *_copyrightURL;
}

#pragma mark - Constants

- (CGSize)preferredViewSize {
	return CGSizeMake(0, (kHBDPWidgetViewControllerHorizontalMargin * 2) + ([@"X" sizeWithAttributes:[%c(SBTodayBulletinCell) defaultTextAttributes]].height * 6));
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

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

	[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(wallpaperDidUpdate) name:HBDPWallpaperDidUpdateNotification object:nil];
}

- (NSString *)buttonLabel {
	return [_copyrightButton attributedTitleForState:UIControlStateNormal].string;
}

- (void)setButtonLabel:(NSString *)buttonLabel {
	[_copyrightButton setAttributedTitle:[[[NSAttributedString alloc] initWithString:buttonLabel attributes:[%c(SBTodayBulletinCell) defaultTextAttributes]] autorelease] forState:UIControlStateNormal];
}

- (void)hostDidPresent {
	[super hostDidPresent];

	if ([NSDictionary dictionaryWithContentsOfFile:kHBDPMetadataPath]) {
		[self wallpaperDidUpdate];
	} else {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("ws.hbang.dailypaper/ForceUpdate"), NULL, NULL, YES);
	}
}

#pragma mark - Actions

- (void)copyrightButtonTapped {
	if (_copyrightURL) {
		[[UIApplication sharedApplication] openURL:_copyrightURL];
	}
}

- (void)wallpaperDidUpdate {
	[_copyrightURL release];

	NSDictionary *metadata = [NSDictionary dictionaryWithContentsOfFile:kHBDPMetadataPath];

	self.buttonLabel = metadata[kHBDPDescriptionKey];
	_copyrightURL = [[NSURL alloc] initWithString:metadata[kHBDPURLKey]];
	_copyrightButton.userInteractionEnabled = _copyrightURL != nil;
}

#pragma mark - Memory management

- (void)dealloc {
	[_copyrightButton release];
	[_copyrightURL release];

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
