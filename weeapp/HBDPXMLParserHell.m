#import "HBDPXMLParserHell.h"

@implementation HBDPXMLParserHell {
	NSXMLParser *_parser;
	NSString *_currentElement;
	NSMutableString *_currentString;
	NSString *_copyright;
	NSURL *_copyrightURL;
	HBDPXMLParserBingCompletion _completion;
}

- (void)loadWithBingMarket:(NSString *)market completion:(HBDPXMLParserBingCompletion)completion {
	_completion = [completion copy];

	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://www.bing.com/hpimagearchive.aspx?format=xml&idx=0&n=1&mbl=1&mkt=%@", market]];
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:nil error:&error];

		if (error) {
			dispatch_async(dispatch_get_main_queue(), ^{
				completion(nil, nil, error);
			});

			return;
		}

		_parser = [[NSXMLParser alloc] initWithData:data];
		_parser.delegate = self;
		[_parser parse];
	});
}

#pragma mark - NSXMLParserDelegate

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary *)attributeDict {
	_currentElement = [elementName copy];
	_currentString = [[NSMutableString alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (![_currentElement isEqualToString:@"copyright"] && ![_currentElement isEqualToString:@"copyrightlink"]) {
		return;
	}

	[_currentString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
	if ([_currentElement isEqualToString:@"copyright"]) {
		_copyright = [_currentString copy];
	} else if ([_currentElement isEqualToString:@"copyrightlink"]) {
		NSURL *url = [NSURL URLWithString:_currentString];

		if (url && ![url.scheme isEqualToString:@"javascript"]) {
			_copyrightURL = [url copy];
		}

		dispatch_async(dispatch_get_main_queue(), ^{
			_completion(_copyright, _copyrightURL, nil);
		});

		[_parser abortParsing];
		[_parser release];
	}

	[_currentElement release];
	[_currentString release];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
	if (parseError.code == NSXMLParserDelegateAbortedParseError) {
		return;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		_completion(nil, nil, parseError);
	});
}

#pragma mark - Memory management

- (void)dealloc {
	[_parser release];
	[_currentElement release];
	[_currentString release];
	[_copyright release];
	[_copyrightURL release];
	[_completion release];

	[super dealloc];
}

@end
