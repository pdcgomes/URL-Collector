//
//  SAPOPunyAPI.m
//  SAPOPuny
//
//  Created by Pedro Gomes on 3/4/11.
//  Copyright 2011 SAPO. All rights reserved.
//

#import "URLShortener.h"
#import "URLShorteningService.h"
#import "SAPOPunyShorteningService.h"
#import "RegexKitLite.h"

//#import "SAPOPunyShorteningService.h"

#define URL_MATCHING_PATTERN	@"(?i)\\b((?:https?://|www\\d{0,3}[.]|[a-z0-9.\\-]+[.][a-z]{2,4}/)(?:[^\\s()<>]+|\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\))+(?:\\(([^\\s()<>]+|(\\([^\\s()<>]+\\)))*\\)|[^\\s`!()\\[\\]{};:'\".,<>?«»“”‘’]))"
#define URL_RFC1808_PATTERN		@"^[^:]+\\:\\/\\/"
@interface URLShortener(Private)

+ (Class)classForServiceKey:(NSString *)serviceKey;

@end 

@implementation URLShortener

@synthesize delegate;

#pragma mark -
#pragma mark Class Methods

+ (BOOL)isValidURL:(NSString *)URL
{
	return [URL isMatchedByRegex:URL_MATCHING_PATTERN];
}

// Currently only checking for the scheme part
+ (BOOL)conformsToRFC1808:(NSString *)URL
{
	return [URL isMatchedByRegex:URL_RFC1808_PATTERN];
}

+ (NSArray *)supportedShorteningServices
{
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"ShorteningServices"];
//	return [NSArray arrayWithObject:@"Puny URL"];
}

+ (Class)classForServiceKey:(NSString *)serviceKey
{
	NSArray *services = [[self class] supportedShorteningServices];
	for(NSDictionary *service in services) {
		if([[service objectForKey:@"ServiceKey"] isEqualToString:serviceKey]) {
			return NSClassFromString([service objectForKey:@"ServiceClass"]);
		}
	}
	
	[[NSException exceptionWithName:@"pt.sapo.macos.urlcollector.InvalidShorteningServiceKeyException" 
							 reason:SKStringWithFormat(@"The provided ServiceKey <%@> does not identify a valid shortening service", serviceKey) 
						   userInfo:nil] raise];
	return nil;
}

#pragma mark -
#pragma mark Dealloc and Initialization

- (void)dealloc
{
	[service release];
	[super dealloc];
}

- (id)initWithServiceKey:(NSString *)serviceKey
{
	Class serviceClass = [[self class] classForServiceKey:serviceKey];
	if(!serviceClass) {
		[[NSException exceptionWithName:@"" reason:@"" userInfo:nil] raise];
	}
	NSAssert([serviceClass conformsToProtocol:@protocol(URLShorteningService)], @"Service class doesn't conform to protocol <URLShorteningService>");
	
	if((self = [super init])) {
		service = [[serviceClass alloc] init];
		service.delegate = self;
	}
	return self;
}

#pragma mark -
#pragma mark Public Methods

- (void)shortenURL:(NSString *)URL
{
	if(![[self class] isValidURL:URL]) {
		[[NSException exceptionWithName:@"" reason:@"" userInfo:nil] raise];
	}
	
	[service shortenURL:URL];
}

#pragma mark -
#pragma mark URLShorteningServiceDelegate

- (void)shorteningService:(URLShorteningService *)service didShortenURL:(NSString *)URL withResult:(NSString *)shortURL
{
	if([self.delegate respondsToSelector:@selector(URLShortener:didShortenURL:withResult:)]) {
		[self.delegate URLShortener:self didShortenURL:URL withResult:shortURL];
	}
}

- (void)shorteningService:(URLShorteningService *)service didFailWithError:(NSError *)error
{
	if([self.delegate respondsToSelector:@selector(URLShortener:didFailWithError:)]) {
		[self.delegate URLShortener:self didFailWithError:error];
	}
}

@end
