#define DAILYPAPER_GLOBAL_M
#import "Global.h"

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
