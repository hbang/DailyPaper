#import "HBDPAboutListController.h"
#import <UIKit/UITableViewCell+Private.h>

@implementation HBDPAboutListController

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"About" target:self] retain];
	}

	return self;
}

@end
