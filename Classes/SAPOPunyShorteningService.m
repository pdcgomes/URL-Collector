//
//  SAPOPunyShorteningService.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "SAPOPunyShorteningService.h"

#import "JSONKit.h"
#import "GTMNSString+URLArguments.h"

@implementation SAPOPunyShorteningService

- (NSString *)requestURLWithURL:(NSString *)theURL
{
	return SKStringWithFormat(@"http://services.sapo.pt/PunyURL/GetCompressedURLByURLJSON?url=%@", [theURL gtm_stringByEscapingForURLArgument]);
}

- (NSString *)processResponse:(NSData *)responseData error:(NSError **)error
{
	NSDictionary *response = [responseData objectFromJSONData];
	TRACE(@"Processed response: %@", response);

	NSString *asciiURL = [response valueForKeyPath:@"punyURL.ascii"];
	if(asciiURL != nil) {
		return asciiURL;
	}
	else {
		if(error) {
			*error = [NSError errorWithDomain:@"" code:-10 userInfo:nil];
		}
	}
	return nil;
}

@end
