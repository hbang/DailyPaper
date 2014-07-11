typedef void (^HBDPXMLParserBingCompletion)(NSString *copyright, NSURL *url, NSError *error);

@interface HBDPXMLParserHell : NSObject <NSXMLParserDelegate>

- (void)loadWithBingMarket:(NSString *)market completion:(HBDPXMLParserBingCompletion)completion;

@end
