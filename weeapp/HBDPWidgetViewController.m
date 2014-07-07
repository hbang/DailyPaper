#import "HBDPWidgetViewController.h"
#import "HBDPXMLParserHell.h"

@implementation HBDPWidgetViewController {
	UIButton *_copyrightButton;
	NSURL *_copyrightURL;
	BOOL _isStale;
	BOOL _isLoading;
}

#pragma mark - Constants

- (CGSize)preferredViewSize {
	return CGSizeMake([super preferredViewSize].width, 88.f);
}

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];

	_isStale = YES;
	_isLoading = NO;

	_copyrightButton = [[UIButton buttonWithType:UIButtonTypeSystem] retain];
	_copyrightButton.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
	_copyrightButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_copyrightButton.titleLabel.textAlignment = NSTextAlignmentLeft;
	_copyrightButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
	_copyrightButton.titleLabel.numberOfLines = 0;
	_copyrightButton.userInteractionEnabled = NO;
	[_copyrightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_copyrightButton setTitle:@"Loading…" forState:UIControlStateNormal];
	[_copyrightButton addTarget:self action:@selector(copyrightButtonTapped) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_copyrightButton];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	if (_isStale && !_isLoading) {
		_isStale = NO;
		_isLoading = YES;

		HBDPXMLParserHell *parser = [[HBDPXMLParserHell alloc] init];
		[parser loadWithBingMarket:@"en-au" completion:^(NSString *copyright, NSURL *url, NSError *error) { // TODO: this
			NSLog(@"%@ %@ %@",copyright,url,error);

			if (error) {
				NSLog(@"dailypaper: failed to load details: %@", error);

				[_copyrightButton setTitle:@"Couldn’t load the wallpaper details." forState:UIControlStateNormal];
				_copyrightButton.userInteractionEnabled = NO;
				_isStale = YES;
			} else {
				[_copyrightButton setTitle:copyright forState:UIControlStateNormal];
				_copyrightButton.userInteractionEnabled = url != nil;
				_copyrightURL = [url copy];
			}

			_isLoading = NO;
			[parser release];
		}];
	}
}

#pragma mark - Actions

- (void)copyrightButtonTapped {
	if (_copyrightURL) {
		[[UIApplication sharedApplication] openURL:_copyrightURL];
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[super dealloc];
}

@end
